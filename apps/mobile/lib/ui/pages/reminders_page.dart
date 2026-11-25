import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsPageLayout(
        title: context.strings.t('reminders'),
        subtitle: context.strings.t('reminderDetail'),
        child: const _ReminderList(),
      );
}

class _ReminderList extends ConsumerStatefulWidget {
  const _ReminderList();

  @override
  ConsumerState<_ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends ConsumerState<_ReminderList> {
  List<Reminder> _reminders = const [];
  String? _businessId;
  List<BusinessLocation> _locations = const [];
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
      final repository = ref.read(repositoryProvider);
      final results = await Future.wait([
        repository.listReminders(),
        repository.listLocations(businessId: bootstrap.businessId),
      ]);
      if (!mounted) return;
      setState(() {
        _businessId = bootstrap.businessId;
        _reminders = results[0] as List<Reminder>;
        _locations = results[1] as List<BusinessLocation>;
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(error, 'Reminders could not be loaded.');
        });
      }
    }
  }

  Future<void> _edit({Reminder? reminder}) async {
    final businessId = _businessId;
    if (businessId == null) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: ReminderEditorSheet(
          reminder: reminder,
          businessId: businessId,
          locations: reminder == null ? _locations : const [],
        ),
      ),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _delete(Reminder reminder) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('reminderDeleteTitle')),
        content: Text(strings.t('reminderDeleteDetail')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.t('deleteReminder')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(repositoryProvider).deleteReminder(reminder.id);
      if (!mounted) return;
      setState(() {
        _reminders =
            _reminders.where((item) => item.id != reminder.id).toList();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.t('reminderDeleted'))));
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              describeDioError(error, 'The reminder could not be deleted.')),
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
        DukaanBanner(
          icon: Icons.info_outline_rounded,
          title: strings.t('notificationDevices'),
          detail: strings.t('pushUnavailable'),
          tone: DukaanTone.neutral,
        ),
        if (_error != null) ...[
          const SizedBox(height: DukaanTokens.space3),
          _ErrorText(_error!),
        ],
        const SizedBox(height: DukaanTokens.space3),
        FilledButton.icon(
          key: const Key('reminder-create'),
          onPressed: online ? () => _edit() : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(strings.t('newReminder')),
        ),
        if (!online) ...[
          const SizedBox(height: DukaanTokens.space2),
          _ErrorText(strings.t('offlineAction')),
        ],
        const SizedBox(height: DukaanTokens.space4),
        if (_reminders.isEmpty)
          DukaanEmptyState(
            icon: Icons.notifications_none_rounded,
            title: strings.t('noReminders'),
            detail: strings.t('reminderDetail'),
          )
        else
          for (final reminder in _reminders)
            DukaanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(reminder.title,
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      DukaanBadge(strings.t(_statusKey(reminder.status))),
                    ],
                  ),
                  const SizedBox(height: DukaanTokens.space2),
                  Text(reminder.body),
                  const SizedBox(height: DukaanTokens.space2),
                  Text(
                    formatDateTime(
                      reminder.scheduledAt,
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: DukaanTokens.textCaption,
                  ),
                  if (reminder.lastError.isNotEmpty) ...[
                    const SizedBox(height: DukaanTokens.space2),
                    _ErrorText(reminder.lastError),
                  ],
                  if (reminder.isScheduled) ...[
                    const SizedBox(height: DukaanTokens.space2),
                    Wrap(
                      spacing: DukaanTokens.space2,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              online ? () => _edit(reminder: reminder) : null,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(strings.t('edit')),
                        ),
                        TextButton.icon(
                          key: Key('reminder-delete-${reminder.id}'),
                          onPressed: online ? () => _delete(reminder) : null,
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: Text(strings.t('delete')),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
      ],
    );
  }

  String _statusKey(String status) => switch (status) {
        'SCHEDULED' => 'scheduled',
        'QUEUED' => 'queued',
        'SENT' => 'sent',
        'CANCELLED' => 'cancelled',
        'FAILED' => 'failed',
        _ => 'notAvailable',
      };
}

class ReminderEditorSheet extends ConsumerStatefulWidget {
  const ReminderEditorSheet({
    required this.businessId,
    required this.locations,
    this.reminder,
    super.key,
  });

  final String businessId;
  final List<BusinessLocation> locations;
  final Reminder? reminder;

  @override
  ConsumerState<ReminderEditorSheet> createState() =>
      _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends ConsumerState<ReminderEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late DateTime _scheduledAt;
  final _dedupeKey = const Uuid().v4();
  String? _locationId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.reminder?.title ?? '');
    _body = TextEditingController(text: widget.reminder?.body ?? '');
    _scheduledAt = widget.reminder?.scheduledAt ??
        DateTime.now().add(const Duration(hours: 1));
    _locationId = widget.reminder?.locationId;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() => _scheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
  }

  Future<void> _save() async {
    final strings = context.strings;
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      setState(() => _error = strings.t('required'));
      return;
    }
    if (!_scheduledAt.isAfter(DateTime.now())) {
      setState(() => _error = strings.t('scheduledAt'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(repositoryProvider);
      final reminder = widget.reminder;
      if (reminder == null) {
        await repository.createReminder({
          'business_id': widget.businessId,
          if (_locationId != null) 'location_id': _locationId,
          'title': _title.text.trim(),
          'body': _body.text.trim(),
          'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
          'dedupe_key': _dedupeKey,
        });
      } else {
        await repository.updateReminder(reminder.id, {
          'title': _title.text.trim(),
          'body': _body.text.trim(),
          'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
        });
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(reminder == null
            ? strings.t('reminderCreated')
            : strings.t('reminderUpdated')),
      ));
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The reminder could not be saved.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(DukaanTokens.space4),
        children: [
          Text(
            widget.reminder == null
                ? strings.t('createReminder')
                : strings.t('editReminder'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DukaanTokens.space3),
          DukaanField(
            label: strings.t('title'),
            child: TextField(
              key: const Key('reminder-title'),
              controller: _title,
              enabled: !_saving,
              maxLength: 120,
              decoration: const InputDecoration(),
            ),
          ),
          const SizedBox(height: DukaanTokens.space3),
          DukaanField(
            label: strings.t('message'),
            child: TextField(
              key: const Key('reminder-body'),
              controller: _body,
              enabled: !_saving,
              maxLength: 500,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(),
            ),
          ),
          const SizedBox(height: DukaanTokens.space3),
          if (widget.reminder == null && widget.locations.isNotEmpty) ...[
            DukaanField(
              label: strings.t('location'),
              child: DropdownButtonFormField<String?>(
                initialValue: _locationId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(strings.t('locationsOptional')),
                  ),
                  for (final location in widget.locations)
                    DropdownMenuItem(
                      value: location.id,
                      child: Text(location.name),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _locationId = value),
              ),
            ),
            const SizedBox(height: DukaanTokens.space3),
          ],
          OutlinedButton.icon(
            onPressed: _saving ? null : _pickDate,
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(
              '${strings.t('scheduledAt')}: '
              '${formatDateTime(_scheduledAt, Localizations.localeOf(context).languageCode)}',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: DukaanTokens.space3),
            _ErrorText(_error!),
          ],
          if (!online) ...[
            const SizedBox(height: DukaanTokens.space3),
            _ErrorText(strings.t('offlineAction')),
          ],
          const SizedBox(height: DukaanTokens.space3),
          FilledButton.icon(
            key: const Key('reminder-save'),
            onPressed: online && !_saving ? _save : null,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(strings.t('save')),
          ),
        ],
      ),
    );
  }
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
