import 'dart:math';

import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/data/api_client.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/routing/app_router.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/pages/imports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// This is deliberately a live, non-hermetic smoke test. It creates two users
/// and a tenant, posts two sales, and leaves them for an operator to purge.
const _e2eEnabled = bool.fromEnvironment('DUKAAN_E2E');

void main() {
  testWidgets(
    'live Android owner and cashier smoke',
    (tester) async {
      final random = Random.secure();
      final nonce = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
      final ownerPhone = _testPhone(random);
      final cashierPhone = _testPhone(random);
      final ownerPassword = _testPassword(random);
      final cashierPassword = _testPassword(random);
      final shopName = 'E2E Smoke $nonce';

      // Print only the cleanup identity. Never print passwords, JWTs, refresh
      // tokens, or the one-time invitation token.
      debugPrint(
        'DUKAAN_E2E_CLEANUP owner_username=phone_$ownerPhone '
        'owner_phone=$ownerPhone cashier_username=phone_$cashierPhone '
        'cashier_phone=$cashierPhone business=$shopName',
      );

      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sessionStore = SecureSessionStore();
      await sessionStore.clear();
      final draftStore = await DriftDraftStore.open();
      final dio = createDio(sessionStore);
      final repository = ApiDukaanRepository(dio);
      addTearDown(() async {
        await draftStore.close();
        dio.close(force: true);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionStoreProvider.overrideWithValue(sessionStore),
            draftStoreProvider.overrideWithValue(draftStore),
          ],
          child: const DukaanApp(),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DukaanApp)),
      );
      await _waitFor(tester, find.byKey(const Key('auth-phone')));

      // Sign up through the real UI, then create the tenant through onboarding.
      await tester.tap(find.text('Create a new account'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), ownerPhone);
      await tester.enterText(find.byType(TextField).at(1), 'E2E Owner');
      await tester.enterText(find.byType(TextField).at(2), ownerPassword);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create a new account'),
      );
      await tester
          .tap(find.widgetWithText(FilledButton, 'Create a new account'));
      await tester.pump(const Duration(seconds: 2));
      debugPrint(
        'DUKAAN_E2E_STAGE stage=${container.read(authControllerProvider)} '
        'route=${container.read(routerProvider).routeInformationProvider.value.uri}',
      );
      _debugVisibleText(tester);
      await _waitFor(
        tester,
        find.text('Set up your shop'),
        timeout: const Duration(seconds: 60),
      );

      await tester.enterText(find.byType(TextField).at(0), shopName);
      await tester.enterText(find.byType(TextField).at(2), 'Main Shop');
      await tester.ensureVisible(find.text('Create my shop'));
      await tester.tap(find.text('Create my shop'));
      await _waitFor(
        tester,
        find.text('Daily AI summary'),
        timeout: const Duration(seconds: 60),
      );

      final bootstrap = await container.read(bootstrapProvider.future);
      final location = await container.read(activeLocationProvider.future);
      expect(bootstrap.role, BusinessRole.owner);
      expect(location.businessId, bootstrap.businessId);

      // The catalog has no create UI yet, so use the real repository/API for
      // setup. The subsequent sale and assistant flows run through the UI.
      final product = await repository.createProduct({
        'business': bootstrap.businessId,
        'name': 'Shirt',
        'sku': 'E2E-SHIRT-$nonce',
        'base_unit': 'PIECE',
        'track_inventory': true,
        'tax_rate_bps': 0,
        'low_stock_threshold': '2',
        'packs': [
          {
            'name': 'Default pack',
            'conversion_factor': '1',
            'retail_price_minor': 10000,
            'wholesale_price_minor': 8000,
          },
        ],
      });
      await repository.adjustStock({
        'business_id': bootstrap.businessId,
        'location_id': location.id,
        'product_id': product.id,
        'quantity_delta': '20',
        'reason': 'E2E smoke opening stock',
      });
      final customer = await repository.createParty({
        'business': bootstrap.businessId,
        'name': 'Ramesh',
        'kind': 'CUSTOMER',
      });
      await repository.createParty({
        'business': bootstrap.businessId,
        'name': 'E2E Supplier',
        'kind': 'SUPPLIER',
      });
      expect(customer.id, isNotEmpty);

      await _openBottomTab(tester, 'Entries');
      await _waitFor(tester, find.byKey(const Key('new-sale-button')));
      await tester.tap(find.byKey(const Key('new-sale-button')));
      await _waitFor(tester, find.byKey(const Key('sale-product')));
      await tester.tap(find.byKey(const Key('sale-product')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shirt').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('sale-quantity')), '2');
      await tester.enterText(find.byKey(const Key('sale-price')), '100');
      await tester.enterText(find.byKey(const Key('sale-paid')), '200');
      await tester.ensureVisible(find.byKey(const Key('review-sale-button')));
      await tester.tap(find.byKey(const Key('review-sale-button')));
      await _waitFor(tester, find.byKey(const ValueKey('sale-review')));

      expect(find.text('This sale has not been recorded yet.'), findsOneWidget);
      expect(await repository.fetchEntries(location.id), hasLength(0));
      await tester.ensureVisible(find.byKey(const Key('confirm-sale-button')));
      await tester.tap(find.byKey(const Key('confirm-sale-button')));
      await _waitFor(
        tester,
        find.text('Entry recorded'),
        timeout: const Duration(seconds: 60),
      );
      expect(await repository.fetchEntries(location.id), hasLength(1));

      // Interpret is review-only. Verify the ledger is unchanged before the
      // separate confirmation action, then verify exactly one additional sale.
      await _openBottomTab(tester, 'Ask / Add');
      await _waitFor(tester, find.byKey(const Key('assistant-input')));
      await tester.enterText(
        find.byKey(const Key('assistant-input')),
        'Ramesh bought 2 shirts for ₹200, paid ₹150, ₹50 pending',
      );
      await tester.tap(find.byKey(const Key('assistant-submit')));
      await _waitFor(
        tester,
        find.byKey(const Key('proposal-confirm')),
        timeout: const Duration(seconds: 120),
      );
      expect(find.text('DukaanAI has not changed your books yet.'),
          findsOneWidget);
      expect(await repository.fetchEntries(location.id), hasLength(1));
      await tester.ensureVisible(find.byKey(const Key('proposal-confirm')));
      await tester.tap(find.byKey(const Key('proposal-confirm')));
      await _waitFor(
        tester,
        find.text('Entry recorded'),
        timeout: const Duration(seconds: 60),
      );
      expect(await repository.fetchEntries(location.id), hasLength(2));

      // Create a second real account, invite it as a cashier, and accept via
      // the real repository/API before switching the app's secure session.
      final cashierStore = MemorySessionStore();
      final cashierDio = createDio(cashierStore);
      final cashierRepository = ApiDukaanRepository(cashierDio);
      addTearDown(() => cashierDio.close(force: true));
      await AuthApi(cashierStore).signup(
        phone: cashierPhone,
        password: cashierPassword,
        displayName: 'E2E Cashier',
      );
      final invitation = await repository.createInvitation({
        'business': bootstrap.businessId,
        'invitee_phone': cashierPhone,
        'role': 'CASHIER',
        'locations': [location.id],
      });
      expect(invitation.token, isNotNull);
      await cashierRepository.acceptInvitation(token: invitation.token!);

      await tester.tap(find.byKey(const Key('open-settings')));
      await _waitFor(tester, find.byKey(const Key('settings-sign-out')));
      await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('settings-sign-out')));
      await tester.tap(find.byKey(const Key('settings-sign-out')));
      await _waitFor(tester, find.byKey(const Key('auth-phone')));

      await tester.enterText(find.byKey(const Key('auth-phone')), cashierPhone);
      await tester.enterText(
          find.byKey(const Key('auth-password')), cashierPassword);
      await tester.tap(find.byKey(const Key('auth-password-submit')));
      await _waitFor(
        tester,
        find.byKey(const Key('cashier-new-sale')),
        timeout: const Duration(seconds: 60),
      );
      expect(container.read(currentBusinessRoleProvider), BusinessRole.cashier);
      expect(find.text('Daily AI summary'), findsNothing);
      expect(find.text('Expenses'), findsNothing);
      expect(find.text('You will pay'), findsNothing);

      await tester.tap(find.byKey(const Key('cashier-new-sale')));
      await _waitFor(tester, find.byKey(const Key('sale-product')));
      expect(find.text('RETAIL'), findsOneWidget);
      expect(find.text('Wholesale'), findsNothing);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await _waitFor(tester, find.byKey(const Key('cashier-new-sale')));

      await _openBottomTab(tester, 'Stock');
      await _waitFor(tester, find.text('Shirt'));
      expect(find.textContaining('Wholesale'), findsNothing);

      await _openBottomTab(tester, 'Parties');
      await _waitFor(tester, find.text('Ramesh'));
      expect(find.text('Suppliers'), findsNothing);
      expect(find.text('E2E Supplier'), findsNothing);
      expect(find.text('You will pay'), findsNothing);

      await tester.tap(find.byKey(const Key('open-settings')));
      await _waitFor(tester, find.byKey(const Key('settings-sign-out')));
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('Team invitations'), findsNothing);
      expect(find.text('Import products or parties'), findsNothing);
      expect(find.text('Valuation & margin'), findsNothing);
      expect(find.text('Payment allocations'), findsNothing);

      // Direct navigation must also fail closed for a cashier.
      container.read(routerProvider).go('/settings/imports');
      await tester.pumpAndSettle();
      expect(find.byType(ImportsPage), findsOneWidget);
      expect(
        find.text('This screen is available to owners and managers only.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
    // Never execute the live body without the explicit opt-in flag.
    skip: !_e2eEnabled,
    timeout: const Timeout(Duration(minutes: 12)),
  );
}

String _testPhone(Random random) {
  final seed =
      '${DateTime.now().microsecondsSinceEpoch}${random.nextInt(1000000)}';
  return '+919${seed.substring(seed.length - 9)}';
}

String _testPassword(Random random) {
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return 'E2e!${List.generate(24, (_) => alphabet[random.nextInt(alphabet.length)]).join()}';
}

Future<void> _openBottomTab(WidgetTester tester, String label) async {
  final tab = find.text(label).last;
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pump();
}

void _debugVisibleText(WidgetTester tester) {
  final labels = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .join(' | ');
  debugPrint('DUKAAN_E2E_TEXT $labels');
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  _debugVisibleText(tester);
  expect(
    finder,
    findsOneWidget,
    reason: 'Timed out waiting for ${finder.toString()} after $timeout.',
  );
}
