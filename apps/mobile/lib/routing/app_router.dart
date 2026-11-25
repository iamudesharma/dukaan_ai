import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/app_shell.dart';
import 'package:dukaan_ai_mobile/ui/pages/assistant_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/imports_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/invitation_acceptance_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/invitations_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/manual_sale_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/notification_devices_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/onboarding_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/operation_forms_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/payment_allocations_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/parties_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/reminders_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/security_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/settings_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/sign_in_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/sign_up_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/stock_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/today_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/valuation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Re-runs GoRouter's redirect whenever the auth stage changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);

  final router = GoRouter(
    initialLocation: '/today',
    refreshListenable: refresh,
    redirect: (context, state) {
      final stage = ref.read(authControllerProvider);
      final path = state.uri.path;
      switch (stage) {
        case AuthStage.loading:
          return path == '/loading' ? null : '/loading';
        case AuthStage.signedOut:
          return path == '/sign-in' || path == '/sign-up' ? null : '/sign-in';
        case AuthStage.needsBusiness:
          return path == '/onboarding' ? null : '/onboarding';
        case AuthStage.ready:
          return path == '/sign-in' ||
                  path == '/sign-up' ||
                  path == '/onboarding' ||
                  path == '/loading'
              ? '/today'
              : null;
      }
    },
    routes: [
      GoRoute(
          path: '/loading', builder: (context, state) => const _LoadingPage()),
      GoRoute(
          path: '/sign-in', builder: (context, state) => const SignInPage()),
      GoRoute(
          path: '/sign-up', builder: (context, state) => const SignUpPage()),
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
              path: '/today', builder: (context, state) => const TodayPage()),
          GoRoute(
              path: '/entries',
              builder: (context, state) => const EntriesPage()),
          GoRoute(
              path: '/ask', builder: (context, state) => const AssistantPage()),
          GoRoute(
              path: '/stock', builder: (context, state) => const StockPage()),
          GoRoute(
              path: '/parties',
              builder: (context, state) => const PartiesPage()),
          GoRoute(
            path: '/sale/new',
            builder: (context, state) => const ManualSalePage(),
          ),
          GoRoute(
            path: '/purchase/new',
            builder: (context, state) => const OperationFormPage(
              type: OperationFormType.purchase,
            ),
          ),
          GoRoute(
            path: '/expense/new',
            builder: (context, state) => const OperationFormPage(
              type: OperationFormType.expense,
            ),
          ),
          GoRoute(
            path: '/payment/new',
            builder: (context, state) => const OperationFormPage(
              type: OperationFormType.payment,
            ),
          ),
          GoRoute(
            path: '/transfer/new',
            builder: (context, state) => const OperationFormPage(
              type: OperationFormType.transfer,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/security',
            builder: (context, state) => const SecurityPage(),
          ),
          GoRoute(
            path: '/settings/invitations',
            builder: (context, state) => const InvitationsPage(),
          ),
          GoRoute(
            path: '/settings/invitations/accept',
            builder: (context, state) => const InvitationAcceptancePage(),
          ),
          GoRoute(
            path: '/settings/imports',
            builder: (context, state) => const ImportsPage(),
          ),
          GoRoute(
            path: '/settings/valuation',
            builder: (context, state) => const ValuationPage(),
          ),
          GoRoute(
            path: '/settings/allocations',
            builder: (context, state) => const PaymentAllocationsPage(),
          ),
          GoRoute(
            path: '/settings/reminders',
            builder: (context, state) => const RemindersPage(),
          ),
          GoRoute(
            path: '/settings/devices',
            builder: (context, state) => const NotificationDevicesPage(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refresh.dispose);
  return router;
});

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
