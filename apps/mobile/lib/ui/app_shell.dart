import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  static const _paths = ['/today', '/entries', '/ask', '/stock', '/parties'];

  int get _selectedIndex {
    if (currentPath.startsWith('/sale/') || currentPath.startsWith('/quick/')) return 1;
    final index = _paths.indexWhere(currentPath.startsWith);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final locations = ref.watch(locationsProvider);
    final active = ref.watch(activeLocationProvider);
    final online = ref.watch(networkStatusProvider).valueOrNull ?? AppConfig.demoMode;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: locations.when(
          loading: () => const _BrandTitle(),
          error: (_, __) => const _BrandTitle(),
          data: (items) => Semantics(
            label: strings.t('location'),
            button: true,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: active.valueOrNull?.id ?? (items.isEmpty ? null : items.first.id),
                icon: const Icon(Icons.expand_more_rounded),
                isDense: true,
                items: items
                    .map(
                      (location) => DropdownMenuItem(
                        value: location.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              location.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedLocationIdProvider.notifier).state = value;
                  }
                },
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: strings.t('reports'),
            onPressed: () => context.go('/reports'),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: strings.t('more'),
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              switch (value) {
                case 'team':
                  context.go('/team');
                case 'activity':
                  context.go('/activity');
                case 'settings':
                  context.go('/settings');
                case 'signout':
                  await ref.read(authApiProvider).logout();
                  bumpSession(ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'team', child: Text(strings.t('team'))),
              PopupMenuItem(value: 'activity', child: Text(strings.t('activity'))),
              PopupMenuItem(value: 'settings', child: Text(strings.t('settings'))),
              PopupMenuItem(value: 'signout', child: Text(strings.t('signOut'))),
            ],
          ),
          IconButton(
            tooltip: strings.t('changeLanguage'),
            onPressed: ref.read(localeProvider.notifier).toggle,
            icon: const Icon(Icons.translate_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (!online)
            _StatusBanner(
              icon: Icons.cloud_off_rounded,
              title: strings.t('offline'),
              detail: strings.t('offlineDetail'),
              color: Theme.of(context).colorScheme.errorContainer,
            )
          else if (AppConfig.demoMode)
            _StatusBanner(
              icon: Icons.science_outlined,
              title: strings.t('demo'),
              detail: strings.t('demoDetail'),
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => context.go(_paths[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today_rounded),
            label: strings.t('today'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: strings.t('entries'),
          ),
          NavigationDestination(
            icon: Semantics(
              label: strings.t('ask'),
              child: const CircleAvatar(
                radius: 19,
                child: Icon(Icons.auto_awesome_rounded),
              ),
            ),
            label: strings.t('ask'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2_rounded),
            label: strings.t('stock'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: strings.t('parties'),
          ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(context.strings.t('appName')),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $detail',
      child: Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$title  ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: detail,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

