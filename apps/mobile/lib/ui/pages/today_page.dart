import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentBusinessRoleProvider);
    if (!role.canManageOperations) {
      final entries = ref.watch(entriesProvider);
      final products = ref.watch(productsProvider);
      return entries.when(
        loading: () => const LoadingContent(),
        error: (error, _) => ErrorContent(
          message: error.toString(),
          onRetry: () => ref.invalidate(entriesProvider),
        ),
        data: (items) => products.when(
          loading: () => const LoadingContent(),
          error: (error, _) => ErrorContent(
            message: error.toString(),
            onRetry: () => ref.invalidate(productsProvider),
          ),
          data: (catalog) {
            final now = DateTime.now();
            final todaysSales = items.where((entry) =>
                entry.type == EntryType.sale &&
                entry.occurredAt.year == now.year &&
                entry.occurredAt.month == now.month &&
                entry.occurredAt.day == now.day);
            return RefreshIndicator(
              onRefresh: () async {
                ref
                  ..invalidate(entriesProvider)
                  ..invalidate(productsProvider)
                  ..invalidate(localDraftsProvider);
                await ref.read(entriesProvider.future);
              },
              child: _CashierTodayBody(
                salesTotalMinor: todaysSales.fold(
                    0, (total, entry) => total + entry.totalMinor),
                saleCount: todaysSales.length,
                lowStockCount:
                    catalog.where((product) => product.isLowStock).length,
              ),
            );
          },
        ),
      );
    }

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

class _CashierTodayBody extends ConsumerWidget {
  const _CashierTodayBody({
    required this.salesTotalMinor,
    required this.saleCount,
    required this.lowStockCount,
  });

  final int salesTotalMinor;
  final int saleCount;
  final int lowStockCount;

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
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker(strings.t('today')),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          strings.t(greetingKey),
          style: DukaanTokens.textDisplay.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        _AssistantPromptCard(strings: strings),
        const SizedBox(height: DukaanTokens.space3),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('cashier-new-sale'),
            onPressed: () => context.go('/sale/new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(strings.t('manualSale')),
          ),
        ),
        const SizedBox(height: DukaanTokens.space6),
        DukaanSectionHeader(
          kicker: '01 · ${strings.t('today')}',
          title: strings.t('salesToday'),
          ruled: true,
        ),
        const SizedBox(height: DukaanTokens.space3),
        DukaanCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t('salesToday'),
                        style: DukaanTokens.textLabel),
                    const SizedBox(height: DukaanTokens.space1),
                    DukaanMoney(formatCompactMoney(salesTotalMinor, locale)),
                  ],
                ),
              ),
              Text('$saleCount ${strings.t('sales').toLowerCase()}'),
            ],
          ),
        ),
        const SizedBox(height: DukaanTokens.space6),
        DukaanSectionHeader(
          kicker: '02 · ${strings.t('today')}',
          title: strings.t('needsAttention'),
          ruled: true,
        ),
        const SizedBox(height: DukaanTokens.space3),
        DukaanListRow(
          showDivider: false,
          leading: const DukaanIconPlate(
            icon: Icons.inventory_2_outlined,
            tone: DukaanTone.attention,
          ),
          title: '$lowStockCount ${strings.t('lowStock').toLowerCase()}',
          trailing: const Icon(Icons.chevron_right_rounded, size: 18),
          onTap: () => context.go('/stock'),
        ),
        if (draftCount > 0)
          DukaanListRow(
            leading: const DukaanIconPlate(
              icon: Icons.edit_note_rounded,
              tone: DukaanTone.neutral,
            ),
            title: '$draftCount ${strings.t('draftsWaiting')}',
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: () => context.go('/entries'),
          ),
      ],
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
    final role = ref.watch(currentBusinessRoleProvider);
    final draftCount = ref.watch(localDraftsProvider).valueOrNull?.length ?? 0;
    final greetingKey = switch (DateTime.now().hour) {
      < 12 => 'goodMorning',
      < 17 => 'goodAfternoon',
      _ => 'goodEvening',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker(strings.t('today')),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          strings.t(greetingKey),
          style: DukaanTokens.textDisplay.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        _AssistantPromptCard(strings: strings),
        const SizedBox(height: DukaanTokens.space6),
        DukaanSectionHeader(
          kicker: '01 · ${strings.t('today')}',
          title: strings.t('salesToday'),
          ruled: true,
        ),
        const SizedBox(height: DukaanTokens.space3),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - DukaanTokens.space3) / 2;
            return Wrap(
              spacing: DukaanTokens.space3,
              runSpacing: DukaanTokens.space4,
              children: [
                SizedBox(
                  width: width,
                  child: DukaanMetricTile(
                    icon: Icons.trending_up_rounded,
                    label: strings.t('salesToday'),
                    value: formatCompactMoney(summary.salesMinor, locale),
                  ),
                ),
                if (role.canManageOperations)
                  SizedBox(
                    width: width,
                    child: DukaanMetricTile(
                      icon: Icons.payments_outlined,
                      label: strings.t('expenses'),
                      value: formatCompactMoney(summary.expensesMinor, locale),
                    ),
                  ),
                SizedBox(
                  width: width,
                  child: DukaanMetricTile(
                    icon: Icons.south_west_rounded,
                    label: strings.t('toReceive'),
                    value: formatCompactMoney(summary.toReceiveMinor, locale),
                    tone: DukaanTone.positive,
                  ),
                ),
                if (role.canManageOperations)
                  SizedBox(
                    width: width,
                    child: DukaanMetricTile(
                      icon: Icons.north_east_rounded,
                      label: strings.t('toPay'),
                      value: formatCompactMoney(summary.toPayMinor, locale),
                      tone: DukaanTone.attention,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: DukaanTokens.space6),
        DukaanSectionHeader(
          kicker: '02 · ${strings.t('today')}',
          title: strings.t('needsAttention'),
          ruled: true,
        ),
        const SizedBox(height: DukaanTokens.space3),
        Column(
          children: [
            DukaanListRow(
              showDivider: false,
              leading: const DukaanIconPlate(
                icon: Icons.inventory_2_outlined,
                tone: DukaanTone.attention,
              ),
              title:
                  '${summary.lowStockCount} ${strings.t('lowStock').toLowerCase()}',
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () => context.go('/stock'),
            ),
            if (draftCount > 0)
              DukaanListRow(
                leading: const DukaanIconPlate(
                  icon: Icons.edit_note_rounded,
                  tone: DukaanTone.neutral,
                ),
                title: '$draftCount ${strings.t('draftsWaiting')}',
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: () => context.go('/entries'),
              ),
          ],
        ),
        if (role.canManageOperations) ...[
          const SizedBox(height: DukaanTokens.space6),
          DukaanSectionHeader(
            kicker: '03 · ${strings.t('today')}',
            title: strings.t('dailySummary'),
            ruled: true,
          ),
          const SizedBox(height: DukaanTokens.space3),
          DukaanHeroCard(
            key: const Key('today-summary-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DukaanHeroEyebrow('Daily summary'),
                const SizedBox(height: DukaanTokens.space2),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: DukaanTokens.colorHeroAccent,
                    ),
                    const SizedBox(width: DukaanTokens.space2),
                    Expanded(
                      child: Text(
                        '${strings.t('asOf')} ${formatDateTime(summary.asOf, locale)}',
                        style: DukaanTokens.textCaption.copyWith(
                          color: DukaanTokens.colorOnHeroMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanHeroText(
                  summary.summary.isEmpty
                      ? 'Your summary will appear after the first entries of the day.'
                      : summary.summary,
                  style: DukaanTokens.textBody,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The one thing on this screen that carries the most weight, so it sits on
/// the ink plane exactly like `.ai-summary-card` does on web.
class _AssistantPromptCard extends StatelessWidget {
  const _AssistantPromptCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${strings.t('assistantPrompt')}. ${strings.t('assistantExample')}',
      child: DukaanHeroCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('today-assistant-card'),
            borderRadius: BorderRadius.circular(DukaanTokens.radiusPanel),
            onTap: () => context.go('/ask'),
            child: Padding(
              padding: const EdgeInsets.all(DukaanTokens.space4),
              child: Row(
                children: [
                  Container(
                    width: DukaanTokens.sizeHit,
                    height: DukaanTokens.sizeHit,
                    decoration: BoxDecoration(
                      color: DukaanTokens.colorHeroAccent,
                      borderRadius:
                          BorderRadius.circular(DukaanTokens.radiusControl),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: DukaanTokens.colorHero,
                    ),
                  ),
                  const SizedBox(width: DukaanTokens.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DukaanHeroText(
                          strings.t('assistantPrompt'),
                          style: DukaanTokens.textSubhead,
                        ),
                        const SizedBox(height: DukaanTokens.space1),
                        Text(
                          strings.t('assistantExample'),
                          style: DukaanTokens.textCaption.copyWith(
                            color: DukaanTokens.colorOnHeroMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DukaanTokens.space2),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: DukaanTokens.colorHeroAccent,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
