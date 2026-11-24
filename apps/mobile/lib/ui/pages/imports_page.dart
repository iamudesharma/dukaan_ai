import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/data/csv_picker.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportsPage extends ConsumerWidget {
  const ImportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(currentBusinessRoleProvider).canManageOperations;
    return SettingsPageLayout(
      title: context.strings.t('importCsv'),
      subtitle: context.strings.t('importCsvDetail'),
      child: ManagerOnlyGate(
        allowed: allowed,
        child: const _ImportManager(),
      ),
    );
  }
}

class _ImportManager extends ConsumerStatefulWidget {
  const _ImportManager();

  @override
  ConsumerState<_ImportManager> createState() => _ImportManagerState();
}

class _ImportManagerState extends ConsumerState<_ImportManager> {
  String? _businessId;
  CsvImportKind _kind = CsvImportKind.product;
  String _duplicateStrategy = 'UPDATE';
  PickedCsv? _file;
  ImportDryRun? _dryRun;
  ImportJob? _prepared;
  List<ImportJob> _jobs = const [];
  bool _loading = true;
  bool _busy = false;
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
      final jobs = await ref
          .read(repositoryProvider)
          .listImports(businessId: bootstrap.businessId);
      if (!mounted) return;
      setState(() {
        _businessId = bootstrap.businessId;
        _jobs = jobs;
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(error, 'Imports could not be loaded.');
        });
      }
    }
  }

  Future<void> _chooseFile() async {
    try {
      final file = await ref.read(csvPickerProvider).pick();
      if (!mounted || file == null) return;
      if (file.bytes.isEmpty || file.bytes.length > 2 * 1024 * 1024) {
        setState(() => _error = context.strings.t('csvTooLarge'));
        return;
      }
      setState(() {
        _file = file;
        _dryRun = null;
        _prepared = null;
        _error = null;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The CSV file could not be opened.'));
      }
    }
  }

  Future<void> _preview() async {
    final file = _file;
    final businessId = _businessId;
    if (file == null || businessId == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _prepared = null;
    });
    try {
      final result = await ref.read(repositoryProvider).previewImport(
            businessId: businessId,
            kind: _kind,
            bytes: file.bytes,
            filename: file.filename,
            duplicateStrategy: _duplicateStrategy,
          );
      if (!mounted) return;
      setState(() {
        _dryRun = result;
        if (!result.canPrepare) _error = context.strings.t('invalidImport');
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The CSV dry-run could not be completed.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _prepare() async {
    final file = _file;
    final businessId = _businessId;
    final preview = _dryRun;
    if (file == null || businessId == null || preview?.canPrepare != true) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final job = await ref.read(repositoryProvider).uploadImport(
            businessId: businessId,
            kind: _kind,
            bytes: file.bytes,
            filename: file.filename,
            duplicateStrategy: _duplicateStrategy,
          );
      if (!mounted) return;
      setState(() {
        _prepared = job;
        _jobs = [job, ..._jobs];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('importPrepared'))),
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The import could not be prepared.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm(ImportJob job) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('confirmImportTitle')),
        content: Text(strings.t('confirmImportDetail')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            key: const Key('import-confirm-dialog-submit'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.t('applyImport')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(repositoryProvider).confirmImport(
            id: job.id,
            idempotencyKey: 'mobile-import:${job.id}',
          );
      if (!mounted) return;
      setState(() {
        _jobs = [
          for (final item in _jobs)
            if (item.id == result.job.id) result.job else item,
        ];
        if (_prepared?.id == result.job.id) _prepared = result.job;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.t('importConfirmed'))));
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The import could not be confirmed.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openJob(ImportJob job) async {
    try {
      final detail = await ref.read(repositoryProvider).fetchImport(job.id);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DukaanTokens.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.originalFilename,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: DukaanTokens.space2),
                _Counts(detail: detail),
                if (detail.errors.isNotEmpty) ...[
                  const SizedBox(height: DukaanTokens.space3),
                  _ImportErrors(errors: detail.errors),
                ],
                if (detail.canConfirm) ...[
                  const SizedBox(height: DukaanTokens.space3),
                  FilledButton.icon(
                    key: Key('import-history-confirm-${detail.id}'),
                    onPressed: _busy ? null : () => _confirm(detail),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(context.strings.t('confirmImport')),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(describeDioError(error, 'The import could not be loaded.')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    if (_loading) return const LoadingContent();
    return ListView(
      children: [
        if (!online) ...[
          DukaanBanner(
            icon: Icons.cloud_off_rounded,
            title: strings.t('offline'),
            detail: strings.t('importOffline'),
          ),
          const SizedBox(height: DukaanTokens.space3),
        ],
        if (_error != null) ...[
          _ErrorText(_error!),
          const SizedBox(height: DukaanTokens.space3),
        ],
        DukaanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<CsvImportKind>(
                key: const Key('import-kind'),
                segments: [
                  ButtonSegment(
                    value: CsvImportKind.product,
                    label: Text(strings.t('products')),
                  ),
                  ButtonSegment(
                    value: CsvImportKind.party,
                    label: Text(strings.t('parties')),
                  ),
                ],
                selected: {_kind},
                showSelectedIcon: false,
                onSelectionChanged: _busy
                    ? null
                    : (value) => setState(() {
                          _kind = value.single;
                          _dryRun = null;
                          _prepared = null;
                        }),
              ),
              const SizedBox(height: DukaanTokens.space3),
              DukaanField(
                label: strings.t('duplicateStrategy'),
                child: DropdownButtonFormField<String>(
                  initialValue: _duplicateStrategy,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'UPDATE',
                      child: Text(
                        strings.t('updateExisting'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'SKIP',
                      child: Text(
                        strings.t('skipExisting'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) => setState(() {
                            _duplicateStrategy = value ?? 'UPDATE';
                            _dryRun = null;
                            _prepared = null;
                          }),
                ),
              ),
              const SizedBox(height: DukaanTokens.space3),
              OutlinedButton.icon(
                key: const Key('import-choose-file'),
                onPressed: _busy ? null : _chooseFile,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: Text(strings.t('chooseCsv')),
              ),
              if (_file != null) ...[
                const SizedBox(height: DukaanTokens.space2),
                Text('${strings.t('selectedFile')}: ${_file!.filename}'),
              ],
              const SizedBox(height: DukaanTokens.space3),
              FilledButton.icon(
                key: const Key('import-dry-run'),
                onPressed: online && !_busy && _file != null ? _preview : null,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fact_check_outlined, size: 18),
                label: Text(strings.t('dryRun')),
              ),
            ],
          ),
        ),
        if (_dryRun != null) ...[
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(strings.t('importPreview'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DukaanTokens.space1),
                Text(strings.t('importNotPosted')),
                const SizedBox(height: DukaanTokens.space3),
                _Counts(detail: _dryRun!),
                if (_dryRun!.errors.isNotEmpty) ...[
                  const SizedBox(height: DukaanTokens.space3),
                  _ImportErrors(errors: _dryRun!.errors),
                ],
                if (_dryRun!.preview.isNotEmpty) ...[
                  const SizedBox(height: DukaanTokens.space3),
                  for (final row in _dryRun!.preview.take(50))
                    DukaanListRow(
                      showDivider: false,
                      title: '${strings.t('rows')} ${row.row}',
                      trailing: DukaanBadge(row.action),
                    ),
                  if (_dryRun!.preview.length > 50)
                    Text(
                        '+${_dryRun!.preview.length - 50} ${strings.t('rows')}'),
                ],
                const SizedBox(height: DukaanTokens.space3),
                OutlinedButton.icon(
                  key: const Key('import-prepare'),
                  onPressed:
                      online && !_busy && _dryRun!.canPrepare ? _prepare : null,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(strings.t('prepareImport')),
                ),
              ],
            ),
          ),
        ],
        if (_prepared != null) ...[
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_prepared!.originalFilename,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DukaanTokens.space2),
                _Counts(detail: _prepared!),
                const SizedBox(height: DukaanTokens.space3),
                FilledButton.icon(
                  key: const Key('import-confirm'),
                  onPressed: online && !_busy && _prepared!.canConfirm
                      ? () => _confirm(_prepared!)
                      : null,
                  icon:
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(strings.t('confirmImport')),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: DukaanTokens.space6),
        Text(strings.t('importHistory'),
            style: Theme.of(context).textTheme.titleMedium),
        if (_jobs.isEmpty)
          DukaanEmptyState(
            icon: Icons.upload_file_outlined,
            title: strings.t('noImportJobs'),
            detail: strings.t('importNotPosted'),
          )
        else
          for (final job in _jobs)
            DukaanCard(
              onTap: () => _openJob(job),
              child: Row(
                children: [
                  const DukaanIconPlate(icon: Icons.description_outlined),
                  const SizedBox(width: DukaanTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.originalFilename,
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                            '${job.kind} · ${job.rowCount} ${strings.t('rows')}'),
                      ],
                    ),
                  ),
                  DukaanBadge(strings.t(_statusKey(job.status))),
                ],
              ),
            ),
      ],
    );
  }

  String _statusKey(String status) => switch (status) {
        'READY' => 'ready',
        'COMPLETED' => 'completed',
        'INVALID' => 'invalid',
        'FAILED' => 'failed',
        _ => 'notAvailable',
      };
}

class _Counts extends StatelessWidget {
  const _Counts({required this.detail});

  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Wrap(
      spacing: DukaanTokens.space4,
      runSpacing: DukaanTokens.space2,
      children: [
        _Count(label: strings.t('rows'), value: detail.rowCount),
        _Count(label: strings.t('validRows'), value: detail.validRowCount),
        _Count(label: strings.t('createCount'), value: detail.createdCount),
        _Count(label: strings.t('updateCount'), value: detail.updatedCount),
        _Count(label: strings.t('skipCount'), value: detail.skippedCount),
        _Count(
          label: strings.t('errors'),
          value: detail.errorCount,
          warning: detail.errorCount > 0,
        ),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(
      {required this.label, required this.value, this.warning = false});

  final String label;
  final int value;
  final bool warning;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DukaanTokens.textCaption),
          Text(
            '$value',
            style: DukaanTokens.textAmount.copyWith(
              color: warning ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ],
      );
}

class _ImportErrors extends StatelessWidget {
  const _ImportErrors({required this.errors});

  final List<Map<String, dynamic>> errors;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.strings.t('errors'),
              style: Theme.of(context).textTheme.titleSmall),
          for (final error in errors)
            Padding(
              padding: const EdgeInsets.only(top: DukaanTokens.space2),
              child: Text(
                error.values.map((value) {
                  if (value is List) return value.join(', ');
                  return value.toString();
                }).join(' · '),
                style: DukaanTokens.textCaption.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: DukaanTokens.textCaption.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
}
