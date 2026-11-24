import 'package:dukaan_ai_mobile/core/theme.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/operation_forms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final customer = const Party(
    id: 'customer-1',
    name: 'Retail Customer',
    phone: '',
    kind: PartyKind.customer,
    toReceiveMinor: 0,
    toPayMinor: 0,
  );
  final supplier = const Party(
    id: 'supplier-1',
    name: 'Wholesale Supplier',
    phone: '',
    kind: PartyKind.supplier,
    toReceiveMinor: 0,
    toPayMinor: 0,
  );
  final both = const Party(
    id: 'both-1',
    name: 'Both Party',
    phone: '',
    kind: PartyKind.both,
    toReceiveMinor: 0,
    toPayMinor: 0,
  );
  final secondLocation = BusinessLocation(
    id: 'location-2',
    businessId: 'business-test',
    name: 'Godown',
  );

  for (final type in [
    OperationFormType.purchase,
    OperationFormType.expense,
    OperationFormType.transfer,
  ]) {
    testWidgets('cashier ${type.name} route fails closed without cost data',
        (tester) async {
      final repository = FakeDukaanRepository(role: BusinessRole.cashier);
      await _pumpPage(
        tester,
        OperationFormPage(type: type),
        role: BusinessRole.cashier,
        repository: repository,
        parties: [customer, supplier],
      );

      expect(
        find.text('This screen is available to owners and managers only.'),
        findsOneWidget,
      );
      expect(find.text('Wholesale Supplier'), findsNothing);
      expect(find.text('Unit cost'), findsNothing);
      expect(repository.purchaseCalls, 0);
      expect(repository.expenseCalls, 0);
      expect(repository.transferCalls, 0);
    });
  }

  testWidgets('cashier receipt is fixed to receipts and hides supplier parties',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    await _pumpPage(
      tester,
      const OperationFormPage(type: OperationFormType.payment),
      role: BusinessRole.cashier,
      repository: repository,
      parties: [customer, supplier, both],
    );

    expect(find.byKey(const Key('payment-direction')), findsNothing);
    expect(find.text('RECEIPT'), findsOneWidget);
    expect(find.text('Wholesale Supplier'), findsNothing);
    expect(find.text('Both Party'), findsNothing);

    await _selectDropdown(tester, 'payment-party', 'Retail Customer');
    await _enter(tester, 'payment-amount', '100.01');
    await _enter(tester, 'payment-reference', 'UPI-123');
    await _tapKey(tester, 'review-payment-button');

    expect(repository.paymentCalls, 0);
    expect(find.text('₹100.01'), findsWidgets);
    expect(find.text('Wholesale Supplier'), findsNothing);
    await _tapKey(tester, 'submit-payment-button');

    expect(repository.paymentCalls, 1);
    expect(repository.lastPaymentPayload?['direction'], 'RECEIPT');
    expect(repository.lastPaymentPayload?['amount_minor'], 10001);
    expect(repository.lastPaymentPayload?['party_id'], 'customer-1');
    expect(repository.lastPaymentPayload?['business_id'], 'business-test');
    expect(repository.lastPaymentPayload?['location_id'], 'location-test');
    expect(
      repository.lastPaymentPayload?['idempotency_key'],
      startsWith('form:'),
    );
  });

  testWidgets('manager purchase supports lines and posts only after submit',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager);
    await _pumpPage(
      tester,
      const OperationFormPage(type: OperationFormType.purchase),
      role: BusinessRole.manager,
      repository: repository,
      parties: [customer, supplier],
    );

    await _selectDropdown(tester, 'purchase-supplier', 'Wholesale Supplier');
    await _enter(tester, 'purchase-bill-number', 'BILL-42');
    await _selectDropdown(tester, 'operation-line-product-0', 'Test shirt');
    await _enter(tester, 'operation-line-quantity-0', '2');
    await _enter(tester, 'operation-line-cost-0', '100.01');
    await _enter(tester, 'operation-line-discount-0', '1.00');
    await _enter(tester, 'purchase-paid', '150');
    await _tapKey(tester, 'review-purchase-button');

    expect(repository.purchaseCalls, 0);
    expect(find.text('₹199.02'), findsOneWidget);
    await _tapKey(tester, 'submit-purchase-button');

    expect(repository.purchaseCalls, 1);
    final payload = repository.lastPurchasePayload!;
    expect(payload['supplier_id'], 'supplier-1');
    expect(payload['supplier_bill_number'], 'BILL-42');
    expect(payload['tax_inclusive'], isFalse);
    expect(payload['paid_amount_minor'], 15000);
    expect(payload['lines'], [
      {
        'pack_id': 'pack-test',
        'quantity': '2',
        'unit_cost_minor': 10001,
        'discount_minor': 100,
      },
    ]);
    expect(payload['idempotency_key'], startsWith('form:'));
  });

  testWidgets('expense validates required fields and posts exact tax paise',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.owner);
    await _pumpPage(
      tester,
      const OperationFormPage(type: OperationFormType.expense),
      role: BusinessRole.owner,
      repository: repository,
    );

    await _tapKey(tester, 'review-expense-button');
    expect(repository.expenseCalls, 0);
    expect(find.text('Required'), findsWidgets);

    await _enter(tester, 'expense-category', 'Electricity');
    await _enter(tester, 'expense-payee', 'Power Board');
    await _enter(tester, 'expense-amount', '120.50');
    await _enter(tester, 'expense-tax', '12.25');
    await _enter(tester, 'expense-note', 'November bill');
    await _tapKey(tester, 'review-expense-button');
    expect(repository.expenseCalls, 0);
    await _tapKey(tester, 'submit-expense-button');

    expect(repository.expenseCalls, 1);
    expect(repository.lastExpensePayload?['category'], 'Electricity');
    expect(repository.lastExpensePayload?['amount_minor'], 12050);
    expect(repository.lastExpensePayload?['tax_amount_minor'], 1225);
    expect(repository.lastExpensePayload?['payee'], 'Power Board');
  });

  testWidgets(
      'stock transfer validates locations and submits acknowledged stock',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager);
    await _pumpPage(
      tester,
      const OperationFormPage(type: OperationFormType.transfer),
      role: BusinessRole.manager,
      repository: repository,
      locations: [repository.location, secondLocation],
    );

    await _selectDropdown(tester, 'operation-line-product-0', 'Test shirt');
    await _enter(tester, 'operation-line-quantity-0', '2.5');
    await _tapKey(tester, 'review-transfer-button');
    expect(repository.transferCalls, 0);
    expect(find.text('Select a location'), findsOneWidget);

    await _selectDropdown(tester, 'transfer-to', 'Godown');
    await tester.tap(find.byKey(const Key('transfer-negative-ack')));
    await tester.pumpAndSettle();
    await _enter(tester, 'transfer-negative-reason', 'Urgent replenishment');
    await _tapKey(tester, 'review-transfer-button');
    expect(repository.transferCalls, 0);
    await _tapKey(tester, 'submit-transfer-button');

    expect(repository.transferCalls, 1);
    final payload = repository.lastTransferPayload!;
    expect(payload['from_location_id'], 'location-test');
    expect(payload['to_location_id'], 'location-2');
    expect(payload['negative_stock_acknowledged'], isTrue);
    expect(payload['negative_stock_reason'], 'Urgent replenishment');
    expect(payload['lines'], [
      {'pack_id': 'pack-test', 'quantity': '2.5'},
    ]);
  });

  testWidgets('offline expense becomes a local draft without posting',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager);
    final store = MemoryDraftStore();
    await _pumpPage(
      tester,
      const OperationFormPage(type: OperationFormType.expense),
      role: BusinessRole.manager,
      repository: repository,
      store: store,
      online: false,
    );

    await _enter(tester, 'expense-category', 'Rent');
    await _enter(tester, 'expense-amount', '1000');
    await _tapKey(tester, 'review-expense-button');
    await _tapKey(tester, 'submit-expense-button');

    expect(repository.expenseCalls, 0);
    expect(find.text('Draft saved on this phone'), findsOneWidget);
    final drafts = await store.listDrafts(
      userId: 'user-test',
      businessId: 'business-test',
    );
    expect(drafts.single.kind, DraftKind.expense);
    expect(drafts.single.payload['operation'], 'expense');
  });

  testWidgets('cashier entry menu offers receipt but no manager operations',
      (tester) async {
    await _pumpPage(
      tester,
      const EntriesPage(),
      role: BusinessRole.cashier,
      repository: FakeDukaanRepository(role: BusinessRole.cashier),
    );

    await tester.tap(find.byKey(const Key('entries-more-actions')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entry-action-receipt')), findsOneWidget);
    expect(find.byKey(const Key('entry-action-purchase')), findsNothing);
    expect(find.byKey(const Key('entry-action-expense')), findsNothing);
    expect(find.byKey(const Key('entry-action-payment')), findsNothing);
    expect(find.byKey(const Key('entry-action-transfer')), findsNothing);
  });

  testWidgets('cashier entries hide supplier-payment drafts', (tester) async {
    final payment = OperationDraft(
      id: 'draft-payment',
      kind: OperationKind.payment,
      businessId: 'business-test',
      locationId: 'location-test',
      payload: const {
        'party_id': 'supplier-1',
        'direction': 'PAYMENT',
        'method': 'CASH',
        'amount_minor': 10001,
      },
      createdAt: DateTime(2026, 11, 24),
    );
    final draft = LocalDraft(
      id: payment.id,
      kind: DraftKind.payment,
      userId: 'user-test',
      businessId: 'business-test',
      locationId: 'location-test',
      label: 'Supplier payment: Wholesale Supplier',
      payload: payment.toLocalJson(),
      createdAt: payment.createdAt,
    );
    await _pumpPage(
      tester,
      const EntriesPage(),
      role: BusinessRole.cashier,
      repository: FakeDukaanRepository(role: BusinessRole.cashier),
      drafts: [draft],
    );

    expect(find.textContaining('Wholesale Supplier'), findsNothing);
    expect(find.text('Supplier payment draft'), findsNothing);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  required BusinessRole role,
  FakeDukaanRepository? repository,
  List<Party> parties = const [],
  List<BusinessLocation>? locations,
  List<LocalDraft> drafts = const [],
  MemoryDraftStore? store,
  bool online = true,
  Size size = const Size(430, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repo = repository ?? FakeDukaanRepository(role: role);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        draftStoreProvider.overrideWithValue(store ?? MemoryDraftStore()),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        networkStatusProvider.overrideWith((ref) => Stream.value(online)),
        currentBusinessRoleProvider.overrideWithValue(role),
        bootstrapProvider.overrideWith(
          (ref) async => BusinessBootstrap(
            userId: repo.userId,
            businessId: repo.businessId,
            role: role,
          ),
        ),
        currentUserProvider.overrideWith(
          (ref) async => CurrentUser(id: repo.userId),
        ),
        activeLocationProvider.overrideWith((ref) async => repo.location),
        locationsProvider.overrideWith(
          (ref) async => locations ?? [repo.location],
        ),
        partiesProvider.overrideWith((ref) async => parties),
        productsProvider.overrideWith(
          (ref) async => [FakeDukaanRepository.product],
        ),
        localDraftsProvider.overrideWith((ref) async => drafts),
        entriesProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        theme: DukaanTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDropdown(
  WidgetTester tester,
  String key,
  String value,
) async {
  final dropdown = find.byKey(Key(key));
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.byKey(Key(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final button = find.byKey(Key(key));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}
