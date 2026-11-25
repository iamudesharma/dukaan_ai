import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/theme.dart';
import 'package:dukaan_ai_mobile/data/csv_picker.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/data/sharing_service.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/imports_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/invitations_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/payment_allocations_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/reminders_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/security_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/settings_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/valuation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('cashier settings hide owner and manager tools', (tester) async {
    await _pumpPage(
      tester,
      const SettingsPage(),
      role: BusinessRole.cashier,
      size: const Size(375, 812),
    );

    expect(find.text('Security'), findsWidgets);
    expect(find.text('Reminders'), findsWidgets);
    expect(find.text('Notification devices'), findsWidgets);
    expect(find.text('Team invitations'), findsNothing);
    expect(find.text('Import products or parties'), findsNothing);
    expect(find.text('Valuation & margin'), findsNothing);
    expect(find.text('Payment allocations'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings remains scrollable in a small landscape viewport',
      (tester) async {
    await _pumpPage(
      tester,
      const SettingsPage(),
      role: BusinessRole.cashier,
      size: const Size(812, 375),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cashier direct import route fails closed without repository I/O',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    await _pumpPage(
      tester,
      const ImportsPage(),
      role: BusinessRole.cashier,
      repository: repository,
    );

    expect(find.text('This screen is available to owners and managers only.'),
        findsOneWidget);
    expect(repository.importPreviewCalls, 0);
    expect(repository.importUploadCalls, 0);
    expect(repository.importConfirmCalls, 0);
  });

  testWidgets('all-device revocation clears tokens only after server success',
      (tester) async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    final repository = FakeDukaanRepository();
    await _pumpPage(
      tester,
      const SecurityPage(),
      role: BusinessRole.owner,
      repository: repository,
      store: store,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SecurityPage)),
    );
    await container.read(authControllerProvider.notifier).refreshStage();

    await tester.enterText(
      find.byKey(const Key('security-revoke-password')),
      'current-password',
    );
    await tester.tap(find.byKey(const Key('security-revoke-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out all devices'));
    await tester.pumpAndSettle();

    expect(repository.revokeSessionsCalls, 1);
    expect(repository.lastCurrentPassword, 'current-password');
    expect(await store.readAccessToken(), isNull);
    expect(await store.readRefreshToken(), isNull);
    expect(container.read(authControllerProvider), AuthStage.signedOut);
  });

  testWidgets('failed all-device revocation keeps the secure session',
      (tester) async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    final repository = FakeDukaanRepository()
      ..revokeSessionsError = _dioFailure('Current password is incorrect.');
    await _pumpPage(
      tester,
      const SecurityPage(),
      role: BusinessRole.owner,
      repository: repository,
      store: store,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SecurityPage)),
    );
    await container.read(authControllerProvider.notifier).refreshStage();

    await tester.enterText(
      find.byKey(const Key('security-revoke-password')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('security-revoke-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out all devices'));
    await tester.pumpAndSettle();

    expect(repository.revokeSessionsCalls, 1);
    expect(await store.readAccessToken(), 'access');
    expect(await store.readRefreshToken(), 'refresh');
    expect(container.read(authControllerProvider), AuthStage.ready);
    expect(find.text('Current password is incorrect.'), findsOneWidget);
  });

  testWidgets('cashier sale entry downloads and shares an authenticated PDF',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    final sharing = _RecordingShareService();
    await _pumpPage(
      tester,
      const EntriesPage(),
      role: BusinessRole.cashier,
      repository: repository,
      sharing: sharing,
      size: const Size(375, 812),
      entries: [
        BusinessEntry(
          id: 'sale-1',
          type: EntryType.sale,
          reference: 'INV-1',
          partyName: 'Ramesh',
          totalMinor: 120000,
          pendingMinor: 0,
          occurredAt: DateTime(2026, 11, 24, 12),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('sale-invoice-sale-1')));
    await tester.pumpAndSettle();

    expect(repository.invoicePdfCalls, 1);
    expect(sharing.filename, 'invoice-sale-1.pdf');
    expect(sharing.mimeType, 'application/pdf');
    expect(sharing.bytes!.take(5), [0x25, 0x50, 0x44, 0x46, 0x2d]);
  });

  testWidgets('CSV import requires a separate explicit confirmation',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager);
    await _pumpPage(
      tester,
      const ImportsPage(),
      role: BusinessRole.manager,
      repository: repository,
      picker: _FakeCsvPicker(),
    );

    await tester.tap(find.byKey(const Key('import-choose-file')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('import-dry-run')));
    await tester.tap(find.byKey(const Key('import-dry-run')));
    await tester.pumpAndSettle();
    expect(repository.importPreviewCalls, 1);
    expect(repository.importConfirmCalls, 0);

    await tester.ensureVisible(find.byKey(const Key('import-prepare')));
    await tester.tap(find.byKey(const Key('import-prepare')));
    await tester.pumpAndSettle();
    expect(repository.importUploadCalls, 1);
    expect(repository.importConfirmCalls, 0);

    await tester.ensureVisible(find.byKey(const Key('import-confirm')));
    await tester.tap(find.byKey(const Key('import-confirm')));
    await tester.pumpAndSettle();
    expect(repository.importConfirmCalls, 0);
    await tester.tap(find.byKey(const Key('import-confirm-dialog-submit')));
    await tester.pumpAndSettle();

    expect(repository.importConfirmCalls, 1);
    expect(
        repository.lastImportConfirmationKey, 'mobile-import:import-created');
  });

  testWidgets('owner invitation shows a one-time token and shares it',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.owner);
    final sharing = _RecordingShareService();
    await _pumpPage(
      tester,
      const InvitationsPage(),
      role: BusinessRole.owner,
      repository: repository,
      sharing: sharing,
    );

    await tester.enterText(
      find.byKey(const Key('invitation-phone')),
      '+919812345678',
    );
    await tester.ensureVisible(find.byKey(const Key('invitation-create')));
    await tester.tap(find.byKey(const Key('invitation-create')));
    await tester.pumpAndSettle();
    expect(repository.invitationCreateCalls, 1);
    expect(find.text('one-time-invitation-token-1234567890'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('invitation-share-token')));
    await tester.tap(find.byKey(const Key('invitation-share-token')));
    await tester.pumpAndSettle();
    expect(sharing.text, contains('one-time-invitation-token-1234567890'));
    expect(sharing.text, contains('+919812345678'));
  });

  testWidgets('payment reallocation requires the full exact paise amount',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager)
      ..allocationReview = PaymentAllocationReview(
        payments: [
          PaymentRecord(
            id: 'payment-1',
            businessId: 'business-test',
            locationId: 'location-test',
            partyId: 'party-1',
            direction: 'RECEIPT',
            method: 'CASH',
            amountMinor: 10001,
            status: 'POSTED',
            allocatedTotalMinor: 0,
            unallocatedTotalMinor: 10001,
            allocations: const [],
          ),
        ],
        totals: const AllocationReviewTotals(
          paymentCount: 1,
          paymentTotalMinor: 10001,
          allocatedTotalMinor: 0,
          unallocatedTotalMinor: 10001,
          outstandingDocumentCount: 1,
          outstandingTotalMinor: 10001,
        ),
        outstandingDocuments: [
          OutstandingDocument(
            documentType: 'SALE',
            documentId: 'sale-1',
            number: 'INV-1',
            grandTotalMinor: 10001,
            paidTotalMinor: 0,
            dueTotalMinor: 10001,
            partyId: 'party-1',
            partyName: 'Ramesh',
          ),
        ],
      );
    await _pumpPage(
      tester,
      const PaymentAllocationsPage(),
      role: BusinessRole.manager,
      repository: repository,
    );

    await tester.tap(find.byKey(const Key('allocation-payment-payment-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('allocation-amount-0')), '100');
    await tester.enterText(
      find.byKey(const Key('allocation-reason')),
      'Correct invoice',
    );
    await tester.ensureVisible(find.byKey(const Key('allocation-save')));
    await tester.tap(find.byKey(const Key('allocation-save')));
    await tester.pumpAndSettle();
    expect(repository.reallocateCalls, 0);
    expect(find.text('Allocate the full payment amount before saving.'),
        findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('allocation-amount-0')), '100.01');
    await tester.tap(find.byKey(const Key('allocation-save')));
    await tester.pumpAndSettle();
    expect(repository.reallocateCalls, 1);
    expect(repository.lastReallocationReason, 'Correct invoice');
    expect(repository.lastReallocatedAllocations, [
      {
        'document_type': 'SALE',
        'document_id': 'sale-1',
        'amount_minor': 10001,
      },
    ]);
    expect(repository.lastReallocationKey, isNotNull);
  });

  testWidgets(
      'valuation keeps unknown costs unavailable instead of inventing margin',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.manager)
      ..valuationReport = ValuationReport(
        inventory: ValuationInventory(
          totalQuantity: Decimal.parse('2.5'),
          averageCostMinor: null,
          totalValueMinor: null,
          knownValueMinor: 12345,
          costingComplete: false,
        ),
        sales: ValuationSales(
          postedSaleCount: 1,
          lineCount: 1,
          netSalesMinor: 50000,
          cogsMinor: 30000,
          grossProfitMinor: null,
          missingCostLineCount: 1,
          costingComplete: false,
        ),
        rows: const [],
      );
    await _pumpPage(
      tester,
      const ValuationPage(),
      role: BusinessRole.manager,
      repository: repository,
      size: const Size(375, 812),
    );

    expect(repository.valuationCalls, 1);
    expect(find.text('Costing incomplete'), findsWidgets);
    expect(find.text('Not available'), findsWidgets);
    expect(find.text('₹123.45'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'reminder creation saves a server reminder without registering push',
      (tester) async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier);
    await _pumpPage(
      tester,
      const RemindersPage(),
      role: BusinessRole.cashier,
      repository: repository,
    );

    await tester.tap(find.byKey(const Key('reminder-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reminder-title')),
      'Call supplier',
    );
    await tester.enterText(
      find.byKey(const Key('reminder-body')),
      'Confirm tomorrow stock',
    );
    await tester.ensureVisible(find.byKey(const Key('reminder-save')));
    await tester.tap(find.byKey(const Key('reminder-save')));
    await tester.pumpAndSettle();

    expect(repository.reminderCreateCalls, 1);
    expect(repository.reminders.single.title, 'Call supplier');
    expect(find.textContaining('No device token is generated or sent.'),
        findsWidgets);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  required BusinessRole role,
  FakeDukaanRepository? repository,
  MemorySessionStore? store,
  _RecordingShareService? sharing,
  _FakeCsvPicker? picker,
  List<BusinessEntry>? entries,
  Size size = const Size(430, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repo = repository ?? FakeDukaanRepository(role: role);
  final session = store ??
      MemorySessionStore(access: 'test-access', refresh: 'test-refresh');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        draftStoreProvider.overrideWithValue(MemoryDraftStore()),
        sessionStoreProvider.overrideWithValue(session),
        networkStatusProvider.overrideWith((ref) => Stream.value(true)),
        currentBusinessRoleProvider.overrideWithValue(role),
        bootstrapProvider.overrideWith(
          (ref) async => BusinessBootstrap(
            userId: repo.userId,
            businessId: repo.businessId,
            role: role,
          ),
        ),
        currentUserProvider.overrideWith(
          (ref) async => CurrentUser(
            id: repo.userId,
            phone: '+919876543210',
            displayName: 'Test User',
          ),
        ),
        activeLocationProvider.overrideWith((ref) async => repo.location),
        locationsProvider.overrideWith((ref) async => [repo.location]),
        localDraftsProvider.overrideWith((ref) async => const []),
        entriesProvider.overrideWith((ref) async => entries ?? const []),
        appShareServiceProvider
            .overrideWithValue(sharing ?? _RecordingShareService()),
        csvPickerProvider.overrideWithValue(picker ?? _FakeCsvPicker()),
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

DioException _dioFailure(String detail) => DioException(
      requestOptions: RequestOptions(path: 'auth/sessions/revoke-all/'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: 'auth/sessions/revoke-all/'),
        statusCode: 400,
        data: {'detail': detail},
      ),
    );

class _FakeCsvPicker implements CsvPicker {
  @override
  Future<PickedCsv?> pick() async => const PickedCsv(
        filename: 'products.csv',
        bytes: [110, 97, 109, 101, 10, 83, 104, 105, 114, 116],
      );
}

class _RecordingShareService implements AppShareService {
  String? text;
  String? filename;
  String? mimeType;
  List<int>? bytes;

  @override
  Future<void> shareText(String value) async {
    text = value;
  }

  @override
  Future<void> shareFile({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    this.filename = filename;
    this.bytes = List<int>.of(bytes);
    this.mimeType = mimeType;
  }
}
