import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/ledger_sheet.dart';
import 'package:dukaan_ai_mobile/ui/common/stock_movements_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsData {
  const _ReportsData({
    required this.sales,
    required this.purchases,
    required this.stock,
    required this.parties,
  });

  final DocumentReport sales;
  final DocumentReport purchases;
  final List<StockRow> stock;
  final List<Party> parties;
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  static const _periods = [2, 1, 0];
  int _period = 2;
  String _groupBy = 'day';
  Future<_ReportsData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  ({DateTime? from, DateTime? to}) _range() {
    final now = DateTime.now();
    switch (_period) {
      case 0:
        final day = DateTime(now.year, now.month, now.day);
        return (from: day, to: day);
      case 1:
        return (from: now.subtract(const Duration(days: 6)), to: now);
      default:
        return (from: DateTime(now.year, now.month), to: now);
    }
  }

  Future<_ReportsData> _load() async {
    final location = await ref.read(activeLocationProvider.future);
    final repository = ref.read(repositoryProvider);
    final range = _range();
    final results = await Future.wait<Object>([
      repository.fetchDocumentReport(
        kind: 'sales',
        locationId: location.id,
        groupBy: _groupBy,
        from: range.from,
        to: range.to,
      ),
      repository.fetchDocumentReport(
        kind: 'purchases',
        locationId: location.id,
        groupBy: _groupBy,
        from: range.from,
        to: range.to,
      ),
      repository.fetchStockReport(businessId: location.businessId, locationId: location.id),
      repository.fetchParties(location.id),
    ]);
    return _ReportsData(
      sales: results[0] as DocumentReport,
      purchases: results[1] as DocumentReport,
      stock: results[2] as List<StockRow>,
      parties: results[3] as List<Party>,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  String _periodLabel(AppStrings strings, int period) => switch (period) {
        0 => strings.t('periodToday'),
        1 => strings.t('periodLast7Days'),
        _ => strings.t('periodThisMonth'),
      };

  String _groupLabel(AppStrings strings, String group) => switch (group) {
        'party' => strings.t('groupByParty'),
        'product' => strings.t('groupByProduct'),
        _ => strings.t('groupByDay'),
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    return FutureBuilder<_ReportsData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContent();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return ErrorContent(
            message: snapshot.error?.toString() ?? strings.t('loadFailed'),
            onRetry: _reload,
          );
        }
        final data = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              Text(
                strings.t('reports'),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final period in _periods)
                    ChoiceChip(
                      label: Text(_periodLabel(strings, period)),
                      selected: _period == period,
                      onSelected: (_) {
                        setState(() => _period = period);
                        _reload();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final group in const ['day', 'party', 'product'])
                    ChoiceChip(
                      label: Text(_groupLabel(strings, group)),
                      selected: _groupBy == group,
                      onSelected: (_) {
                        setState(() => _groupBy = group);
                        _reload();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _ReportSection(
                title: strings.t('sales'),
                report: data.sales,
                locale: locale,
                emptyLabel: strings.t('noReportData'),
              ),
              const SizedBox(height: 18),
              _ReportSection(
                title: strings.t('purchases'),
                report: data.purchases,
                locale: locale,
                emptyLabel: strings.t('noReportData'),
              ),
              const SizedBox(height: 18),
              Text(
                strings.t('stockReport'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (data.stock.isEmpty)
                Text(strings.t('noReportData'))
              else
                Card(
                  child: Column(
                    children: [
                      for (final row in data.stock)
                        ListTile(
                          title: Text(row.name),
                          subtitle: Text(
                            '${row.quantity} ${row.unit}'
                            '${row.isLowStock ? ' · ${strings.t('lowStock')}' : ''}',
                          ),
                          trailing: const Icon(Icons.history_rounded, size: 20),
                          onTap: () => showStockMovementsSheet(context, ref, row: row),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                strings.t('partyLedger'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (data.parties.isEmpty)
                Text(strings.t('noReportData'))
              else
                Card(
                  child: Column(
                    children: [
                      for (final party in data.parties)
                        ListTile(
                          title: Text(party.name),
                          subtitle: Text(party.kind.name),
                          trailing: Text(
                            formatMoney(party.toReceiveMinor - party.toPayMinor, locale),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () => showPartyLedgerSheet(context, ref, party: party),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.report,
    required this.locale,
    required this.emptyLabel,
  });

  final String title;
  final DocumentReport report;
  final String locale;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (report.rows.isEmpty)
          Text(emptyLabel)
        else
          Card(
            child: Column(
              children: [
                for (final row in report.rows)
                  ListTile(
                    dense: true,
                    title: Text(row.label),
                    subtitle: row.quantity == null ? null : Text('${row.quantity} units'),
                    trailing: Text(
                      formatMoney(row.grandTotalMinor, locale),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
                  trailing: Text(
                    formatMoney(report.totals.grandTotalMinor, locale),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
