import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the ledger entries for one party at the active location.
Future<void> showPartyLedgerSheet(
  BuildContext context,
  WidgetRef ref, {
  required Party party,
}) async {
  final strings = context.strings;
  final locale = Localizations.localeOf(context).languageCode;
  try {
    final location = await ref.read(activeLocationProvider.future);
    final report = await ref
        .read(repositoryProvider)
        .fetchPartyLedger(businessId: location.businessId, partyId: party.id);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            party.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('${strings.t('receivable')}: ${formatMoney(party.toReceiveMinor, locale)}'),
          const SizedBox(height: 12),
          if (report.entries.isEmpty)
            Text(strings.t('noReportData'))
          else
            for (final entry in report.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text((entry['note'] ?? entry['account'] ?? '').toString()),
                subtitle: Text(
                  DateTime.tryParse((entry['occurred_at'] ?? '').toString()) == null
                      ? ''
                      : formatDateTime(
                          DateTime.parse(entry['occurred_at'].toString()),
                          locale,
                        ),
                ),
                trailing: Text(
                  formatMoney(minorFrom(entry['amount_minor']), locale),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
        ],
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${strings.t('loadFailed')} $error')),
    );
  }
}
