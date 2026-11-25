import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('operation draft keeps exact paise and reapplies scope and key', () {
    final draft = OperationDraft(
      id: 'draft-payment',
      kind: OperationKind.payment,
      businessId: 'business-test',
      locationId: 'location-test',
      payload: const {
        'party_id': 'party-1',
        'direction': 'RECEIPT',
        'method': 'UPI',
        'amount_minor': 10001,
        'business_id': 'wrong-business',
        'location_id': 'wrong-location',
        'idempotency_key': 'wrong-key',
      },
      createdAt: DateTime.utc(2026, 11, 24),
    );

    final restored = OperationDraft.fromLocalJson(draft.toLocalJson());
    final payload = restored.toApiJson('draft:draft-payment');

    expect(restored.kind, OperationKind.payment);
    expect(payload['amount_minor'], 10001);
    expect(payload['direction'], 'RECEIPT');
    expect(payload['business_id'], 'business-test');
    expect(payload['location_id'], 'location-test');
    expect(payload['idempotency_key'], 'draft:draft-payment');
    expect(restored.canBeRecordedBy(BusinessRole.cashier), isTrue);
    expect(
      restored.copyWith(direction: 'PAYMENT').canBeRecordedBy(
            BusinessRole.cashier,
          ),
      isFalse,
    );
  });

  test('offline operation draft is retained and never posts', () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = _draft(OperationKind.expense);
    await store.saveDraft(draft);
    final container = _container(repository, store, online: false);

    final result = await container
        .read(draftSyncProvider.notifier)
        .sendOperationDraft(draft);

    expect(result.synced, isFalse);
    expect(repository.expenseCalls, 0);
    expect(await _drafts(store), hasLength(1));
  });

  test('explicit operation send posts once with a stable key and deletes it',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = _draft(OperationKind.purchase);
    final other = _draft(OperationKind.expense, id: 'draft-other');
    await store.saveDraft(draft);
    await store.saveDraft(other);
    final container = _container(repository, store, online: true);
    await container.read(currentDraftScopeProvider.future);

    final result = await container
        .read(draftSyncProvider.notifier)
        .sendOperationDraft(draft);

    expect(result.synced, isTrue);
    expect(repository.purchaseCalls, 1);
    expect(repository.lastPurchasePayload?['idempotency_key'],
        'draft:draft-purchase');
    expect((await _drafts(store)).single.id, other.id);
  });

  test('cashier can explicitly send a receipt draft', () async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    final store = MemoryDraftStore();
    final draft = _draft(OperationKind.payment, direction: 'RECEIPT');
    await store.saveDraft(draft);
    final container = _container(repository, store, online: true);
    await container.read(bootstrapProvider.future);

    final result = await container
        .read(draftSyncProvider.notifier)
        .sendOperationDraft(draft);

    expect(result.synced, isTrue);
    expect(repository.paymentCalls, 1);
    expect(repository.lastPaymentPayload?['direction'], 'RECEIPT');
  });

  test('cashier cannot send supplier payment or manager operation drafts',
      () async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    final store = MemoryDraftStore();
    final drafts = [
      _draft(OperationKind.payment, id: 'payment', direction: 'PAYMENT'),
      _draft(OperationKind.purchase, id: 'purchase'),
      _draft(OperationKind.expense, id: 'expense'),
      _draft(OperationKind.transfer, id: 'transfer'),
    ];
    for (final draft in drafts) {
      await store.saveDraft(draft);
    }
    final container = _container(repository, store, online: true);
    await container.read(bootstrapProvider.future);

    for (final draft in drafts) {
      final result = await container
          .read(draftSyncProvider.notifier)
          .sendOperationDraft(draft);
      expect(result.synced, isFalse, reason: draft.kind.name);
    }

    expect(repository.paymentCalls, 0);
    expect(repository.purchaseCalls, 0);
    expect(repository.expenseCalls, 0);
    expect(repository.transferCalls, 0);
    expect(await _drafts(store), hasLength(4));
  });
}

ProviderContainer _container(
  FakeDukaanRepository repository,
  MemoryDraftStore store, {
  required bool online,
}) {
  final container = ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(repository),
      draftStoreProvider.overrideWithValue(store),
      sessionStoreProvider.overrideWithValue(
        MemorySessionStore(access: 'access', refresh: 'refresh'),
      ),
      networkStatusProvider.overrideWith((ref) => Stream.value(online)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

LocalDraft _draft(
  OperationKind kind, {
  String id = 'draft-purchase',
  String direction = 'RECEIPT',
}) {
  final payload = switch (kind) {
    OperationKind.purchase => {
        'supplier_id': 'supplier-1',
        'lines': [
          {
            'pack_id': 'pack-test',
            'quantity': '2',
            'unit_cost_minor': 10001,
            'discount_minor': 0,
          },
        ],
      },
    OperationKind.expense => {
        'category': 'Electricity',
        'amount_minor': 12000,
        'tax_amount_minor': 0,
        'payment_method': 'CASH',
      },
    OperationKind.payment => {
        'party_id': 'party-1',
        'direction': direction,
        'method': 'CASH',
        'amount_minor': 10001,
      },
    OperationKind.transfer => {
        'from_location_id': 'location-test',
        'to_location_id': 'location-2',
        'lines': [
          {'pack_id': 'pack-test', 'quantity': '2.5'},
        ],
      },
  };
  final operation = OperationDraft(
    id: id,
    kind: kind,
    businessId: 'business-test',
    locationId: 'location-test',
    payload: payload,
    createdAt: DateTime.utc(2026, 11, 24),
  );
  return LocalDraft(
    id: id,
    kind: kind.draftKind,
    userId: 'user-test',
    businessId: 'business-test',
    locationId: 'location-test',
    label: kind.name,
    payload: operation.toLocalJson(),
    createdAt: operation.createdAt,
  );
}

Future<List<LocalDraft>> _drafts(MemoryDraftStore store) =>
    store.listDrafts(userId: 'user-test', businessId: 'business-test');

extension on OperationDraft {
  OperationDraft copyWith({required String direction}) => OperationDraft(
        id: id,
        kind: kind,
        businessId: businessId,
        locationId: locationId,
        payload: {...payload, 'direction': direction},
        createdAt: createdAt,
      );
}
