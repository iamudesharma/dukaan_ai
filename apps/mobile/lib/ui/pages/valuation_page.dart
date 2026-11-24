import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ValuationPage extends ConsumerWidget {
  const ValuationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(currentBusinessRoleProvider).canManageOperations;
    return SettingsPageLayout(
      title: context.strings.t('valuationReport'),
      subtitle: context.strings.t('valuationDetail'),
      child: ManagerOnlyGate(
        allowed: allowed,
        child: const _ValuationReport(),
      ),
    );
  }
}

class _ValuationReport extends ConsumerStatefulWidget {
  const _ValuationReport();

  @override
  ConsumerState<_ValuationReport> createState() => _ValuationReportState();
}

class _ValuationReportState extends ConsumerState<_ValuationReport> {
  ValuationReport? _report;
  DateTime? _from;
  DateTime? _to;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bootstrap = await ref.read(bootstrapProvider.future);
      final location = await ref.read(activeLocationProvider.future);
      final report = await ref.read(repositoryProvider).fetchValuationReport(
            businessId: bootstrap.businessId,
            locationId: location.id,
            dateFrom: _from?.toIso8601String().split('T').first,
            dateTo: _to?.toIso8601String().split('T').first,
          );
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(error, 'Valuation could not be loaded.');
        });
      }
    }
  }

  Future<void> _pickDate({required bool from}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: (from ? _from : _to) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (from) {
        _from = selected;
      } else {
        _to = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    if (_loading) return const LoadingContent();
    final report = _report;
    if (report == null) {
      return ErrorContent(
        message: _error,
        onRetry: _load,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Wrap(
            spacing: DukaanTokens.space2,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickDate(from: true),
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(_from == null
                    ? strings.t('dateFrom')
                    : '${strings.t('dateFrom')}: ${_from!.toIso8601String().split('T').first}'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDate(from: false),
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(_to == null
                    ? strings.t('dateTo')
                    : '${strings.t('dateTo')}: ${_to!.toIso8601String().split('T').first}'),
              ),
              if (_from != null || _to != null)
                TextButton(
                  onPressed: () => setState(() {
                    _from = null;
                    _to = null;
                  }),
                  child: Text(strings.t('cancel')),
                ),
              FilledButton.tonalIcon(
                key: const Key('valuation-apply-dates'),
                onPressed: _load,
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: Text(strings.t('refreshReport')),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: DukaanTokens.space3),
            _ErrorText(_error!),
          ],
          const SizedBox(height: DukaanTokens.space4),
          DukaanHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DukaanHeroEyebrow(strings.t('valuationReport')),
                const SizedBox(height: DukaanTokens.space2),
                DukaanHeroText(
                  _money(report.inventory.totalValueMinor, locale,
                      report.inventory.costingComplete),
                  style: DukaanTokens.textDisplay,
                ),
                const SizedBox(height: DukaanTokens.space1),
                DukaanHeroText(strings.t('inventoryValue')),
                const SizedBox(height: DukaanTokens.space3),
                DukaanHeroText(
                  report.inventory.costingComplete
                      ? strings.t('costingComplete')
                      : strings.t('costingIncomplete'),
                  style: DukaanTokens.textCaption,
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            child: Column(
              children: [
                _ValueRow(
                  label: strings.t('knownInventoryValue'),
                  value: formatExactMoney(
                      report.inventory.knownValueMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('averageCost'),
                  value: _money(report.inventory.averageCostMinor, locale,
                      report.inventory.costingComplete),
                ),
                _ValueRow(
                  label: strings.t('netSales'),
                  value: formatExactMoney(report.sales.netSalesMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('cogs'),
                  value: formatExactMoney(report.sales.cogsMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('grossProfit'),
                  value: _money(report.sales.grossProfitMinor, locale,
                      report.sales.costingComplete),
                  strong: true,
                ),
              ],
            ),
          ),
          if (!report.sales.costingComplete) ...[
            const SizedBox(height: DukaanTokens.space3),
            DukaanBanner(
              icon: Icons.info_outline_rounded,
              title: strings.t('costingIncomplete'),
              detail:
                  '${report.sales.missingCostLineCount} ${strings.t('unknownCost')}',
              tone: DukaanTone.attention,
            ),
          ],
          const SizedBox(height: DukaanTokens.space6),
          Text(strings.t('products'),
              style: Theme.of(context).textTheme.titleMedium),
          if (report.rows.isEmpty)
            DukaanEmptyState(
              icon: Icons.inventory_2_outlined,
              title: strings.t('noValuationRows'),
              detail: strings.t('valuationDetail'),
            )
          else
            for (final row in report.rows)
              DukaanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(row.name,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        DukaanBadge(
                          row.costingComplete
                              ? strings.t('costingComplete')
                              : strings.t('costingIncomplete'),
                          tone: row.costingComplete
                              ? DukaanTone.positive
                              : DukaanTone.attention,
                        ),
                      ],
                    ),
                    const SizedBox(height: DukaanTokens.space2),
                    _ValueRow(
                      label: strings.t('quantity'),
                      value: '${row.quantity} ${row.unit}',
                    ),
                    _ValueRow(
                      label: strings.t('averageCost'),
                      value: _money(
                          row.averageCostMinor, locale, row.costingComplete),
                    ),
                    _ValueRow(
                      label: strings.t('inventoryValue'),
                      value: _money(
                          row.totalValueMinor, locale, row.costingComplete),
                    ),
                    if (!row.costingComplete)
                      _ValueRow(
                        label: strings.t('unknownCost'),
                        value: '${row.unknownCostQuantity} ${row.unit}',
                        warning: true,
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _money(int? minor, String locale, bool complete) =>
      minor == null || !complete
          ? context.strings.t('notAvailable')
          : formatExactMoney(minor, locale);
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool strong;
  final bool warning;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: DukaanTokens.space3),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: (strong
                        ? DukaanTokens.textAmountLarge
                        : DukaanTokens.textAmount)
                    .copyWith(
                  color: warning ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: DukaanTokens.textCaption.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
}
