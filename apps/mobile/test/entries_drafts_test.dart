import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/core/theme.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/pages/assistant_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fakes.dart';

void main() {
  LocalDraft assistantDraft({String userId = 'user-test'}) => LocalDraft(
        id: 'draft-assistant',
        kind: DraftKind.assistant,
        userId: userId,
        businessId: 'business-test',
        locationId: 'location-test',
        label: 'Ramesh sale request',
        payload: const {
          'input': {
            'type': 'text',
            'content': 'Ramesh bought two shirts',
            'display_text': 'Ramesh sale request',
          },
        },
        createdAt: DateTime(2026, 1, 1),
      );

  LocalDraft saleDraft() => LocalDraft(
        id: 'draft-sale',
        kind: DraftKind.sale,
        userId: 'user-test',
        businessId: 'business-test',
        locationId: 'location-test',
        label: 'Manual sale: Test shirt',
        payload: SaleDraft(
          id: 'sale-1',
          businessId: 'business-test',
          locationId: 'location-test',
          customerName: 'Ramesh',
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
          priceMode: PriceMode.retail,
          paymentMethod: PaymentMethod.cash,
        ).toLocalJson(),
        createdAt: DateTime(2026, 1, 1),
      );

  Future<GoRouter> pumpEntries(
    WidgetTester tester, {
    required MemoryDraftStore store,
    FakeDukaanRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = repository ?? FakeDukaanRepository();
    final router = GoRouter(
      initialLocation: '/entries',
      routes: [
        GoRoute(
          path: '/entries',
          builder: (_, __) => const Scaffold(body: EntriesPage()),
        ),
        GoRoute(
          path: '/ask',
          builder: (_, __) => const Scaffold(body: AssistantPage()),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          draftStoreProvider.overrideWithValue(store),
          sessionStoreProvider.overrideWithValue(
            MemorySessionStore(access: 'access', refresh: 'refresh'),
          ),
          networkStatusProvider.overrideWith((ref) => Stream.value(true)),
          currentBusinessRoleProvider.overrideWithValue(BusinessRole.owner),
          activeLocationProvider.overrideWith((ref) async => repo.location),
          entriesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(
          theme: DukaanTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('assistant draft Review opens proposal and requires Confirm',
      (tester) async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = assistantDraft();
    await store.saveDraft(draft);
    await pumpEntries(tester, store: store, repository: repository);

    expect(find.text('Sync now'), findsNothing);
    await tester.tap(find.byKey(const Key('review-draft-draft-assistant')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposal-confirm')), findsOneWidget);
    expect(repository.interpretCalls, 1);
    expect(repository.confirmCalls, 0);
    expect(
        await store.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        hasLength(1));

    await tester.tap(find.byKey(const Key('proposal-confirm')));
    await tester.pumpAndSettle();
    expect(repository.confirmCalls, 1);
    expect(
        await store.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
  });

  testWidgets('sale draft Review exposes one explicit Send action',
      (tester) async {
    final repository = FakeDukaanRepository();
    final store = MemoryDraftStore();
    final draft = saleDraft();
    await store.saveDraft(draft);
    await pumpEntries(tester, store: store, repository: repository);

    await tester.tap(find.byKey(const Key('review-draft-draft-sale')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('send-sale-draft-draft-sale')), findsOneWidget);
    expect(repository.saleCalls, 0);

    await tester.tap(find.byKey(const Key('send-sale-draft-draft-sale')));
    await tester.pumpAndSettle();
    expect(repository.saleCalls, 1);
    expect(
        await store.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
  });

  testWidgets('Discard asks for confirmation and removes only the scoped draft',
      (tester) async {
    final store = MemoryDraftStore();
    await store.saveDraft(saleDraft());
    await store.saveDraft(assistantDraft(userId: 'user-other'));
    await pumpEntries(tester, store: store);

    expect(find.text('Ramesh sale request'), findsNothing);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this draft?'), findsOneWidget);
    await tester.tap(find.text('Discard').last);
    await tester.pumpAndSettle();

    expect(
        await store.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
    expect(
        await store.listDrafts(
          userId: 'user-other',
          businessId: 'business-test',
        ),
        hasLength(1));
  });
}
