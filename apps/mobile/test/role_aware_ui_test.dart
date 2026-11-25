import 'dart:async';

import 'package:dukaan_ai_mobile/core/theme.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/pages/assistant_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/manual_sale_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/parties_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/stock_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/today_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final sale = BusinessEntry(
    id: 'sale',
    type: EntryType.sale,
    reference: 'INV-1',
    partyName: 'Sale Customer',
    totalMinor: 120000,
    pendingMinor: 0,
    occurredAt: DateTime.now(),
  );
  final purchase = BusinessEntry(
    id: 'purchase',
    type: EntryType.purchase,
    reference: 'PUR-1',
    partyName: 'Supplier Purchase',
    totalMinor: 50000,
    pendingMinor: 0,
    occurredAt: DateTime.now(),
  );
  final expense = BusinessEntry(
    id: 'expense',
    type: EntryType.expense,
    reference: 'EXP-1',
    partyName: 'Electricity',
    totalMinor: 10000,
    pendingMinor: 0,
    occurredAt: DateTime.now(),
  );
  final payment = BusinessEntry(
    id: 'payment',
    type: EntryType.payment,
    reference: 'PAY-1',
    partyName: 'Sale Customer',
    totalMinor: 20000,
    pendingMinor: 0,
    occurredAt: DateTime.now(),
  );
  final entries = [sale, purchase, expense, payment];

  final parties = [
    const Party(
      id: 'customer',
      name: 'Retail Customer',
      phone: '',
      kind: PartyKind.customer,
      toReceiveMinor: 12000,
      toPayMinor: 0,
    ),
    const Party(
      id: 'supplier',
      name: 'Wholesale Supplier',
      phone: '',
      kind: PartyKind.supplier,
      toReceiveMinor: 0,
      toPayMinor: 34000,
    ),
  ];

  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    required BusinessRole role,
    FakeDukaanRepository? repository,
    List<BusinessEntry>? entryItems,
    int Function()? onDashboard,
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
          draftStoreProvider.overrideWithValue(MemoryDraftStore()),
          sessionStoreProvider.overrideWithValue(
            MemorySessionStore(access: 'access', refresh: 'refresh'),
          ),
          networkStatusProvider.overrideWith((ref) => Stream.value(true)),
          currentBusinessRoleProvider.overrideWithValue(role),
          activeLocationProvider.overrideWith((ref) async => repo.location),
          localDraftsProvider.overrideWith((ref) async => const []),
          productsProvider
              .overrideWith((ref) async => [FakeDukaanRepository.product]),
          partiesProvider.overrideWith((ref) async => parties),
          entriesProvider.overrideWith((ref) async => entryItems ?? entries),
          dashboardProvider.overrideWith((ref) async {
            onDashboard?.call();
            return DashboardSummary(
              salesMinor: 120000,
              expensesMinor: 10000,
              toReceiveMinor: 12000,
              toPayMinor: 34000,
              lowStockCount: 0,
              asOf: DateTime.now(),
              summary: 'Manager summary',
            );
          }),
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

  testWidgets('cashier stock shows retail prices but no wholesale prices',
      (tester) async {
    await pumpPage(tester, const StockPage(), role: BusinessRole.cashier);

    expect(find.text('Test shirt'), findsOneWidget);
    expect(find.textContaining('Wholesale'), findsNothing);
    expect(find.text('Retail Customer'), findsNothing);
  });

  for (final role in [BusinessRole.owner, BusinessRole.manager]) {
    testWidgets('${role.name} stock includes wholesale prices', (tester) async {
      await pumpPage(tester, const StockPage(), role: role);
      expect(find.textContaining('Wholesale'), findsOneWidget);
    });
  }

  testWidgets('cashier parties hide suppliers and payable balances',
      (tester) async {
    await pumpPage(tester, const PartiesPage(), role: BusinessRole.cashier);

    expect(find.text('Retail Customer'), findsOneWidget);
    expect(find.text('Suppliers'), findsNothing);
    expect(find.text('Wholesale Supplier'), findsNothing);
    expect(find.text('You will pay'), findsNothing);
  });

  for (final role in [BusinessRole.owner, BusinessRole.manager]) {
    testWidgets('${role.name} parties include supplier views', (tester) async {
      await pumpPage(tester, const PartiesPage(), role: role);
      expect(find.text('Suppliers'), findsOneWidget);
      expect(find.text('Wholesale Supplier'), findsOneWidget);
    });
  }

  testWidgets('cashier entries hide purchase and expense filters and rows',
      (tester) async {
    await pumpPage(tester, const EntriesPage(), role: BusinessRole.cashier);

    expect(find.text('Sales'), findsWidgets);
    expect(find.text('Purchases'), findsNothing);
    expect(find.text('Expenses'), findsNothing);
    expect(find.text('Supplier Purchase'), findsNothing);
    expect(find.text('Electricity'), findsNothing);
    expect(find.text('Sale Customer'), findsWidgets);
    expect(find.byKey(const Key('new-sale-button')), findsOneWidget);
  });

  for (final role in [BusinessRole.owner, BusinessRole.manager]) {
    testWidgets('${role.name} entries include operations filters',
        (tester) async {
      await pumpPage(tester, const EntriesPage(), role: role);
      expect(find.text('Purchases'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Supplier Purchase'), findsOneWidget);
    });
  }

  testWidgets('cashier manual sale is retail-only', (tester) async {
    await pumpPage(tester, const ManualSalePage(), role: BusinessRole.cashier);
    expect(find.text('RETAIL'), findsOneWidget);
    expect(find.text('Wholesale'), findsNothing);
  });

  for (final role in [BusinessRole.owner, BusinessRole.manager]) {
    testWidgets('${role.name} manual sale offers wholesale pricing',
        (tester) async {
      await pumpPage(tester, const ManualSalePage(), role: role);
      expect(find.text('Wholesale'), findsOneWidget);
    });
  }

  testWidgets('cashier home never requests dashboard or manager collections',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    var dashboardCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          draftStoreProvider.overrideWithValue(MemoryDraftStore()),
          sessionStoreProvider.overrideWithValue(
            MemorySessionStore(access: 'access', refresh: 'refresh'),
          ),
          networkStatusProvider.overrideWith((ref) => Stream.value(true)),
          currentBusinessRoleProvider.overrideWithValue(BusinessRole.cashier),
          activeLocationProvider
              .overrideWith((ref) async => repository.location),
          localDraftsProvider.overrideWith((ref) async => const []),
          dashboardProvider.overrideWith((ref) async {
            dashboardCalls++;
            throw StateError('Cashier must not request dashboard.');
          }),
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
          home: const Scaffold(body: TodayPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(dashboardCalls, 0);
    expect(repository.entryCollectionCalls, ['sales', 'payments']);
    expect(repository.entryCollectionCalls, isNot(contains('purchases')));
    expect(repository.entryCollectionCalls, isNot(contains('expenses')));
    expect(repository.entryCollectionCalls, isNot(contains('transfers')));
    expect(find.byKey(const Key('cashier-new-sale')), findsOneWidget);
    expect(find.text('Expenses'), findsNothing);
    expect(find.text('You will pay'), findsNothing);
    expect(find.text('Daily AI summary'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final role in [BusinessRole.owner, BusinessRole.manager]) {
    testWidgets('${role.name} home keeps manager metrics', (tester) async {
      var dashboardCalls = 0;
      await pumpPage(
        tester,
        const TodayPage(),
        role: role,
        onDashboard: () => dashboardCalls++,
        size: const Size(430, 3000),
      );
      expect(dashboardCalls, 1);
      expect(find.text('EXPENSES'), findsOneWidget);
      expect(find.text('YOU WILL PAY'), findsOneWidget);
      expect(find.text('Daily AI summary'), findsOneWidget);
    });
  }

  testWidgets('cashier assistant can review sales but not purchases',
      (tester) async {
    final repository = _PurchaseProposalRepository();
    await pumpPage(
      tester,
      const AssistantPage(),
      role: BusinessRole.cashier,
      repository: repository,
      size: const Size(430, 3000),
    );
    await tester.enterText(
        find.byKey(const Key('assistant-input')), 'Bought shirts');
    await tester.tap(find.byKey(const Key('assistant-submit')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AssistantPage)),
    );
    expect(container.read(currentBusinessRoleProvider), BusinessRole.cashier);
    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.needsDetails);
    expect(container.read(assistantControllerProvider).proposal?.commandType,
        'PURCHASE');
    expect(container.read(assistantControllerProvider).errorKey,
        'cashierSalesOnly');
    expect(find.textContaining('Cashiers can review and record sales only'),
        findsOneWidget);
    expect(find.byKey(const Key('proposal-confirm')), findsNothing);
    expect(repository.confirmCalls, 0);
  });

  testWidgets('document OCR shows progress and opens review without posting',
      (tester) async {
    final upload = Completer<String>();
    final repository = _BlockingImageRepository(upload.future);
    await pumpPage(
      tester,
      const AssistantPage(),
      role: BusinessRole.owner,
      repository: repository,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AssistantPage)),
    );
    await container.read(networkStatusProvider.future);

    unawaited(
        container.read(assistantControllerProvider.notifier).interpretImage(
      bytes: [1, 2, 3],
      mimeType: 'image/png',
      label: 'receipt.png',
    ));
    await tester.pump();
    expect(find.text('Reading your document…'), findsOneWidget);
    expect(repository.confirmCalls, 0);

    upload.complete('attachment-image');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('proposal-confirm')), findsOneWidget);
    expect(repository.confirmCalls, 0);
    expect(repository.uploadedImageBytes, [1, 2, 3]);
  });
}

class _PurchaseProposalRepository extends FakeDukaanRepository {
  @override
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  }) async {
    interpretCalls++;
    return AssistantProposal.fromJson({
      'id': 'proposal-purchase',
      'status': 'READY',
      'command_type': 'PURCHASE',
      'preview': 'Purchase from supplier',
      'blocking_questions': const [],
      'payload': const {},
    });
  }
}

class _BlockingImageRepository extends FakeDukaanRepository {
  _BlockingImageRepository(this.upload);

  final Future<String> upload;

  @override
  Future<String> uploadImageAttachment({
    required String businessId,
    required String mime,
    required List<int> bytes,
  }) async {
    imageUploadCalls++;
    uploadedImageBytes = List<int>.of(bytes);
    uploadedImageMime = mime;
    return upload;
  }

  @override
  Future<AssistantProposal> createProposalFromImage({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  }) async {
    fromImageCalls++;
    return AssistantProposal.fromJson({
      'id': 'proposal-image',
      'status': 'READY',
      'command_type': 'SALE',
      'content': 'Scanned sale receipt',
      'preview': 'Sale from receipt',
      'blocking_questions': const [],
      'payload': const {},
    });
  }
}
