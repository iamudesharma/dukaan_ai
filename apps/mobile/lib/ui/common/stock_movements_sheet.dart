import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the movement history for one product at the active location.
Future<void> showStockMovementsSheet(
  BuildContext context,
  WidgetRef ref, {
  required StockRow row,
}) async {
  final strings = context.strings;
  final locale = Localizations.localeOf(context).languageCode;
  try {
    final location = await ref.read(activeLocationProvider.future);
    final movements = await ref
        .read(repositoryProvider)
        .fetchStockMovements(locationId: location.id, productId: row.productId);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            '${row.name} · ${strings.t('movements')}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (movements.isEmpty)
            Text(strings.t('noMovements'))
          else
            for (final movement in movements)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(movement.movementType.replaceAll('_', ' ')),
                subtitle: Text(formatDateTime(movement.occurredAt, locale)),
                trailing: Text(
                  movement.quantity,
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
