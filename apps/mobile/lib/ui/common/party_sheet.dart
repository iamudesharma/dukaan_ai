import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add or edit a party: name, type and optional phone.
Future<bool> showPartySheet(
  BuildContext context,
  WidgetRef ref, {
  Party? party,
}) async {
  final strings = context.strings;
  final name = TextEditingController(text: party?.name ?? '');
  final phone = TextEditingController(text: party?.phone ?? '');
  var kind = party?.kind ?? PartyKind.customer;
  String? error;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          24 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              party == null ? strings.t('addParty') : strings.t('editParty'),
              style: Theme.of(sheetContext)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: strings.t('partyName')),
            ),
            const SizedBox(height: 12),
            SegmentedButton<PartyKind>(
              segments: [
                ButtonSegment(value: PartyKind.customer, label: Text(strings.t('kindCustomer'))),
                ButtonSegment(value: PartyKind.supplier, label: Text(strings.t('kindSupplier'))),
                ButtonSegment(value: PartyKind.both, label: Text(strings.t('kindBoth'))),
              ],
              selected: {kind},
              onSelectionChanged: (value) => setSheetState(() => kind = value.single),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: strings.t('phoneOptional')),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  setSheetState(() => error = strings.t('required'));
                  return;
                }
                try {
                  final repository = ref.read(repositoryProvider);
                  final normalized =
                      phone.text.replaceAll(RegExp(r'[\s()-]'), '');
                  if (party == null) {
                    await repository.createParty({
                      'name': name.text.trim(),
                      'kind': kind.name.toUpperCase(),
                      if (normalized.isNotEmpty) 'phone_e164': normalized,
                    });
                  } else {
                    await repository.updateParty(party.id, {
                      'name': name.text.trim(),
                      'kind': kind.name.toUpperCase(),
                      'phone_e164': normalized,
                    });
                  }
                  ref.invalidate(partiesProvider);
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
                } on Object catch (err) {
                  setSheetState(() => error = err.toString());
                }
              },
              child: Text(strings.t('saveParty')),
            ),
          ],
        ),
      ),
    ),
  );
  name.dispose();
  phone.dispose();
  if ((saved ?? false) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.t('partySaved'))),
    );
  }
  return saved ?? false;
}
