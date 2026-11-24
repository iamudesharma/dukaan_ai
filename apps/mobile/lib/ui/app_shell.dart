import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  static const _paths = ['/today', '/entries', '/ask', '/stock', '/parties'];

  int get _selectedIndex {
    if (currentPath.startsWith('/sale/')) return 1;
    final index = _paths.indexWhere(currentPath.startsWith);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final locations = ref.watch(locationsProvider);
    final active = ref.watch(activeLocationProvider);
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: DukaanTokens.space4,
        title: locations.when(
          loading: () => const _BrandTitle(),
          error: (_, __) => const _BrandTitle(),
          data: (items) => Semantics(
            label: strings.t('location'),
            button: true,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: active.valueOrNull?.id ??
                    (items.isEmpty ? null : items.first.id),
                icon: const Icon(Icons.expand_more_rounded, size: 20),
                isDense: true,
                borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
                style:
                    DukaanTokens.textSubhead.copyWith(color: scheme.onSurface),
                items: items
                    .map(
                      (location) => DropdownMenuItem(
                        value: location.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront_rounded, size: 18),
                            const SizedBox(width: DukaanTokens.space2),
                            Text(location.name,
                                style: DukaanTokens.textSubhead),
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
            tooltip: strings.t('changeLanguage'),
            onPressed: ref.read(localeProvider.notifier).toggle,
            icon: const Icon(Icons.translate_rounded, size: 22),
          ),
          IconButton(
            key: const Key('open-settings'),
            tooltip: strings.t('settings'),
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
          const SizedBox(width: DukaanTokens.space1),
        ],
      ),
      body: Column(
        children: [
          if (!online)
            // Offline means drafts only. That is attention, not failure.
            DukaanBanner(
              icon: Icons.cloud_off_rounded,
              title: strings.t('offline'),
              detail: strings.t('offlineDetail'),
              tone: DukaanTone.attention,
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
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: DukaanTokens.colorHero,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: DukaanTokens.colorOnHero,
                ),
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
        Container(
          width: DukaanTokens.sizeTile,
          height: DukaanTokens.sizeTile,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 20,
            color: DukaanTokens.colorOnPrimary,
          ),
        ),
        const SizedBox(width: DukaanTokens.space3),
        Text(
          context.strings.t('appName'),
          style: DukaanTokens.textSubhead,
        ),
      ],
    );
  }
}
