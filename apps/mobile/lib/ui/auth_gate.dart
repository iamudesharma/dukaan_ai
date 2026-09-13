import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/pages/login_page.dart';
import 'package:dukaan_ai_mobile/ui/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decides what the user sees before the business shell:
/// sign-in when there is no token, onboarding when the account owns no
/// business, otherwise the wrapped child.
class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionTokenProvider);
    return session.when(
      loading: () => const Scaffold(body: LoadingContent()),
      error: (_, __) => const LoginPage(),
      data: (token) {
        if (token == null || token.isEmpty) return const LoginPage();
        final businesses = ref.watch(businessesProvider);
        return businesses.when(
          loading: () => const Scaffold(body: LoadingContent()),
          error: (_, __) => const LoginPage(),
          data: (items) => items.isEmpty ? const OnboardingPage() : child,
        );
      },
    );
  }
}
