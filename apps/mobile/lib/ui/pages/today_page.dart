import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return dashboard.when(
      loading: () => const LoadingContent(),
      error: (error, _) => ErrorContent(
        message: error.toString(),
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
      data: (summary) => RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(dashboardProvider)
            ..invalidate(entriesProvider)
            ..invalidate(productsProvider)
            ..invalidate(partiesProvider);
          await ref.read(dashboardProvider.future);
        },
        child: _TodayBody(summary: summary),
      ),
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    final draftCount = ref.watch(localDraftsProvider).valueOrNull?.length ?? 0;
    final greetingKey = switch (DateTime.now().hour) {
      < 12 => 'goodMorning',
      < 17 => 'goodAfternoon',
      _ => 'goodEvening',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(
          strings.t(greetingKey),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: '${strings.t('assistantPrompt')}. ${strings.t('assistantExample')}',
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              key: const Key('today-assistant-card'),
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/ask'),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: const Icon(Icons.auto_awesome_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.t('assistantPrompt'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(strings.t('assistantExample')),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _SectionTitle(title: strings.t('today')),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricCard(
                  width: width,
                  icon: Icons.trending_up_rounded,
                  label: strings.t('salesToday'),
                  value: formatCompactMoney(summary.salesMinor, locale),
                ),
                _MetricCard(
                  width: width,
                  icon: Icons.payments_outlined,
                  label: strings.t('expenses'),
                  value: formatCompactMoney(summary.expensesMinor, locale),
                ),
                _MetricCard(
                  width: width,
                  icon: Icons.south_west_rounded,
                  label: strings.t('toReceive'),
                  value: formatCompactMoney(summary.toReceiveMinor, locale),
                ),
                _MetricCard(
                  width: width,
                  icon: Icons.north_east_rounded,
                  label: strings.t('toPay'),
                  value: formatCompactMoney(summary.toPayMinor, locale),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _SectionTitle(title: strings.t('needsAttention')),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              _AttentionRow(
                icon: Icons.inventory_2_outlined,
                title: '${summary.lowStockCount} ${strings.t('lowStock').toLowerCase()}',
                onTap: () => context.go('/stock'),
              ),
              if (draftCount > 0) ...[
                const Divider(height: 1),
                _AttentionRow(
                  icon: Icons.edit_note_rounded,
                  title: '$draftCount ${strings.t('draftsWaiting')}',
                  onTap: () => context.go('/entries'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        _SectionTitle(title: strings.t('dailySummary')),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${strings.t('asOf')} ${formatDateTime(summary.asOf, locale)}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  summary.summary.isEmpty
                      ? 'Your summary will appear after the first entries of the day.'
                      : summary.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, $value',
      child: SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                ExcludeSemantics(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(height: 3),
                ExcludeSemantics(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 58,
      leading: Icon(icon, color: Theme.of(context).colorScheme.error),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
