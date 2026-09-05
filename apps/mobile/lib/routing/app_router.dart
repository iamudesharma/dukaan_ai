import 'package:dukaan_ai_mobile/ui/app_shell.dart';
import 'package:dukaan_ai_mobile/ui/pages/assistant_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/entries_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/manual_sale_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/parties_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/stock_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/today_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
          GoRoute(path: '/entries', builder: (context, state) => const EntriesPage()),
          GoRoute(path: '/ask', builder: (context, state) => const AssistantPage()),
          GoRoute(path: '/stock', builder: (context, state) => const StockPage()),
          GoRoute(path: '/parties', builder: (context, state) => const PartiesPage()),
          GoRoute(
            path: '/sale/new',
            builder: (context, state) => const ManualSalePage(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

