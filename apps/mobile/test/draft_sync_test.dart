import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  SaleDraft testSale({
    String businessId = 'business-test',
    PriceMode priceMode = PriceMode.retail,
  }) =>
      SaleDraft(
        id: 'sale-1',
        businessId: businessId,
        locationId: 'location-test',
        lines: [
          SaleLineDraft(
            productId: 'product-test',
            packId: 'pack-test',
            productName: 'Test shirt',
            quantity: Decimal.fromInt(2),
            unitPriceMinor: 80000,
          ),
        ],
        paidAmountMinor: 160000,
        priceMode: priceMode,
        paymentMethod: PaymentMethod.cash,
      );

  LocalDraft saleDraft({
    String id = 'draft-sale',
    String userId = 'user-test',
    String businessId = 'business-test',
    PriceMode priceMode = PriceMode.retail,
  }) =>
      LocalDraft(
        id: id,
        kind: DraftKind.sale,
        userId: userId,
        businessId: businessId,
        locationId: 'location-test',
        label: 'Manual sale',
        payload: testSale(
          businessId: businessId,
          priceMode: priceMode,
        ).toLocalJson(),
        createdAt: DateTime.utc(2026, 1, 1),
      );

  const input = AssistantInput(
    type: AssistantInputType.text,
    content: 'Ramesh bought two shirts',
    displayText: 'Ramesh bought two shirts',
  );

  AssistantProposal proposal({
    String command = 'SALE',
    int version = 1,
    Map<String, dynamic> rawPayload = const {},
  }) =>
      AssistantProposal(
        id: 'proposal-test',
        version: version,
        status: 'READY',
        commandType: command,
        title: 'Sale to Ramesh',
        facts: const [ReviewFact('Total', '₹1,600')],
        warnings: const [],
        blockingQuestions: const [],
        rawPayload: rawPayload,
      );

  LocalDraft assistantDraft({
    String id = 'draft-assistant',
    String userId = 'user-test',
    String businessId = 'business-test',
    AssistantProposal? storedProposal,
  }) =>
      LocalDraft(
        id: id,
        kind: DraftKind.assistant,
        userId: userId,
        businessId: businessId,
        locationId: 'location-test',
        label: input.displayText,
        payload: {
          'input': input.toJson(),
          if (storedProposal != null) 'proposal': storedProposal.toJson(),
        },
        createdAt: DateTime.utc(2026, 1, 1),
      );

  ProviderContainer testContainer({
    required FakeDukaanRepository repository,
    required MemoryDraftStore draftStore,
    required bool online,
    String userId = 'user-test',
    String businessId = 'business-test',
  }) {
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        draftStoreProvider.overrideWithValue(draftStore),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        networkStatusProvider.overrideWith((ref) => Stream.value(online)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<List<LocalDraft>> draftsFor(
    MemoryDraftStore store, {
    String userId = 'user-test',
    String businessId = 'business-test',
  }) =>
      store.listDrafts(userId: userId, businessId: businessId);

  test('sale drafts never send while offline and need an explicit send',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = saleDraft();
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: false,
    );
    await container.read(networkStatusProvider.future);

    final offlineResult =
        await container.read(draftSyncProvider.notifier).sendSaleDraft(draft);

    expect(offlineResult.synced, isFalse);
    expect(repository.saleCalls, 0);
    expect(await draftsFor(store), hasLength(1));
  });

  test('an explicit per-sale send posts once and deletes only that draft',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = saleDraft();
    final other = saleDraft(id: 'draft-other');
    await store.saveDraft(draft);
    await store.saveDraft(other);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);

    final result =
        await container.read(draftSyncProvider.notifier).sendSaleDraft(draft);

    expect(result.synced, isTrue);
    expect(repository.saleCalls, 1);
    expect((await draftsFor(store)).single.id, other.id);
  });

  test('assistant review interprets but never confirms or deletes', () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = assistantDraft();
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);

    final result = await container
        .read(draftSyncProvider.notifier)
        .reviewAssistantDraft(draft);

    expect(result.proposal?.id, 'proposal-test');
    expect(result.error, isNull);
    expect(repository.interpretCalls, 1);
    expect(repository.confirmCalls, 0);
    final stored = (await draftsFor(store)).single;
    expect(stored.payload['proposal'], isA<Map>());
  });

  test('assistant confirmation is a separate explicit action', () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = assistantDraft();
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);
    final controller = container.read(draftSyncProvider.notifier);
    final review = await controller.reviewAssistantDraft(draft);
    expect(repository.confirmCalls, 0);

    final confirmation =
        await controller.confirmAssistantDraft(draft, review.proposal!);

    expect(confirmation.synced, isTrue);
    expect(repository.confirmCalls, 1);
    expect(await draftsFor(store), isEmpty);
  });

  test('stored assistant proposals open review without re-interpreting',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = assistantDraft(storedProposal: proposal());
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);
    final controller = container.read(draftSyncProvider.notifier);

    final review = await controller.reviewAssistantDraft(draft);
    expect(review.proposal?.id, 'proposal-test');
    expect(repository.interpretCalls, 0);
    expect(repository.confirmCalls, 0);

    await controller.confirmAssistantDraft(draft, review.proposal!);
    expect(repository.confirmCalls, 1);
  });

  test(
      'stale proposals refresh for another human confirmation, never auto-post',
      () async {
    final repository = _StaleOnceRepository();
    final store = MemoryDraftStore();
    final draft = assistantDraft(storedProposal: proposal());
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);
    final controller = container.read(draftSyncProvider.notifier);

    final first = await controller.confirmAssistantDraft(draft, proposal());

    expect(first.synced, isFalse);
    expect(first.refreshedProposal?.version, 2);
    expect(repository.confirmCalls, 1);
    expect(repository.refreshCalls, 1);
    expect(await draftsFor(store), hasLength(1));

    final second =
        await controller.confirmAssistantDraft(draft, first.refreshedProposal!);
    expect(second.synced, isTrue);
    expect(repository.confirmCalls, 2);
    expect(await draftsFor(store), isEmpty);
  });

  test(
      'cross-user and cross-business drafts cannot be reviewed, sent, or deleted',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final otherUser = assistantDraft(userId: 'user-other');
    final otherBusiness = saleDraft(businessId: 'business-other');
    await store.saveDraft(otherUser);
    await store.saveDraft(otherBusiness);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(currentDraftScopeProvider.future);
    final controller = container.read(draftSyncProvider.notifier);

    expect((await controller.reviewAssistantDraft(otherUser)).error, isNotNull);
    expect((await controller.sendSaleDraft(otherBusiness)).synced, isFalse);
    await expectLater(controller.discardDraft(otherUser), throwsStateError);

    expect(repository.interpretCalls, 0);
    expect(repository.saleCalls, 0);
    expect(await draftsFor(store), isEmpty);
    expect(await draftsFor(store, userId: 'user-other'), hasLength(1));
    expect(await draftsFor(store, businessId: 'business-other'), hasLength(1));
  });

  test('current business role comes from bootstrap for every role', () async {
    for (final role in BusinessRole.values) {
      final container = testContainer(
        repository: FakeDukaanRepository(role: role),
        draftStore: MemoryDraftStore(),
        online: true,
      );
      await container.read(bootstrapProvider.future);
      expect(container.read(currentBusinessRoleProvider), role);
    }
  });

  test('localDraftsProvider exposes only the /me user and bootstrap business',
      () async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    await store.saveDraft(saleDraft());
    await store.saveDraft(saleDraft(id: 'other-user', userId: 'user-other'));
    await store.saveDraft(
        saleDraft(id: 'other-business', businessId: 'business-other'));
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );

    final drafts = await container.read(localDraftsProvider.future);

    expect(drafts.map((draft) => draft.id), ['draft-sale']);
    expect(repository.meCalls, greaterThanOrEqualTo(1));
    expect(repository.bootstrapCalls, greaterThanOrEqualTo(1));
  });

  test('cashier cannot confirm an assistant purchase draft', () async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    final store = MemoryDraftStore();
    final purchase = proposal(command: 'PURCHASE');
    final draft = assistantDraft(storedProposal: purchase);
    await store.saveDraft(draft);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(bootstrapProvider.future);

    final review = await container
        .read(draftSyncProvider.notifier)
        .reviewAssistantDraft(draft);
    final confirmation = await container
        .read(draftSyncProvider.notifier)
        .confirmAssistantDraft(draft, review.proposal!);

    expect(confirmation.synced, isFalse);
    expect(repository.confirmCalls, 0);
    expect(await draftsFor(store), hasLength(1));
  });

  test('cashier cannot send wholesale sales or confirm wholesale proposals',
      () async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    final store = MemoryDraftStore();
    final sale = saleDraft(priceMode: PriceMode.wholesale);
    final assistant = assistantDraft(
      storedProposal: proposal(rawPayload: const {'price_mode': 'WHOLESALE'}),
    );
    await store.saveDraft(sale);
    await store.saveDraft(assistant);
    final container = testContainer(
      repository: repository,
      draftStore: store,
      online: true,
    );
    await container.read(bootstrapProvider.future);
    final controller = container.read(draftSyncProvider.notifier);

    expect((await controller.sendSaleDraft(sale)).synced, isFalse);
    final review = await controller.reviewAssistantDraft(assistant);
    expect(
      (await controller.confirmAssistantDraft(assistant, review.proposal!))
          .synced,
      isFalse,
    );
    expect(repository.saleCalls, 0);
    expect(repository.confirmCalls, 0);
    expect(await draftsFor(store), hasLength(2));
  });

  testWidgets('reconnecting the shell never posts queued drafts',
      (tester) async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = saleDraft();
    await store.saveDraft(draft);
    final connectivity = StreamController<bool>();
    addTearDown(connectivity.close);
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        draftStoreProvider.overrideWithValue(store),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        networkStatusProvider.overrideWith((ref) => connectivity.stream),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AppShell(currentPath: '/entries', child: SizedBox.shrink()),
        ),
      ),
    );
    connectivity.add(false);
    await tester.pumpAndSettle();
    expect(find.textContaining('Offline — draft only', findRichText: true),
        findsOneWidget);

    connectivity.add(true);
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline — draft only', findRichText: true),
        findsNothing);
    expect(repository.saleCalls, 0);
    expect(repository.interpretCalls, 0);
    expect(repository.confirmCalls, 0);
    expect(await draftsFor(store), hasLength(1));
    expect(container.read(draftSyncProvider).busy, isFalse);
  });
}

class _StaleOnceRepository extends FakeDukaanRepository {
  int refreshCalls = 0;

  @override
  Future<PostedResult> confirmProposal(AssistantProposal proposal) async {
    confirmCalls++;
    if (confirmCalls > 1) {
      return const PostedResult(
          id: 'sale-test', reference: 'INV-TEST', message: 'Saved');
    }
    final options =
        RequestOptions(path: 'assistant/proposals/${proposal.id}/confirm/');
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<Object>(
        requestOptions: options,
        statusCode: 409,
        data: const {
          'error': {
            'detail': {'code': 'stale_proposal_data'},
          },
        },
      ),
    );
  }

  @override
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal) async {
    refreshCalls++;
    return AssistantProposal(
      id: proposal.id,
      version: 2,
      status: 'READY',
      commandType: 'SALE',
      title: 'Updated sale review',
      facts: const [ReviewFact('Total', '₹1,700')],
      warnings: const [],
      blockingQuestions: const [],
      rawPayload: const {},
    );
  }
}
