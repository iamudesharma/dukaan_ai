import 'package:dukaan_ai_mobile/ui/app_shell.dart';
import 'package:dukaan_ai_mobile/ui/auth_gate.dart';
import 'package:dukaan_ai_mobile/ui/pages/assistant_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/manual_sale_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/parties_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/quick_entry_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/reports_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/settings_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/stock_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/team_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/today_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AuthGate(
          child: AppShell(
            currentPath: state.uri.path,
            child: child,
          ),
        ),
        routes: [
          GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
          GoRoute(path: '/entries', builder: (context, state) => const EntriesPage()),
          GoRoute(path: '/ask', builder: (context, state) => const AssistantPage()),
          GoRoute(path: '/stock', builder: (context, state) => const StockPage()),
          GoRoute(path: '/parties', builder: (context, state) => const PartiesPage()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/team', builder: (context, state) => const TeamPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          GoRoute(
            path: '/sale/new',
            builder: (context, state) => const ManualSalePage(),
          ),
          GoRoute(
            path: '/quick/:kind',
            builder: (context, state) => QuickEntryPage(
              kind: state.pathParameters['kind'] == 'expense' ? QuickKind.expense : QuickKind.purchase,
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

