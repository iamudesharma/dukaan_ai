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

class NotificationDevicesPage extends ConsumerWidget {
  const NotificationDevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsPageLayout(
        title: context.strings.t('notificationDevices'),
        subtitle: context.strings.t('notificationDevicesDetail'),
        child: const _DeviceList(),
      );
}

class _DeviceList extends ConsumerStatefulWidget {
  const _DeviceList();

  @override
  ConsumerState<_DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends ConsumerState<_DeviceList> {
  List<NotificationDevice> _devices = const [];
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
      final devices =
          await ref.read(repositoryProvider).listNotificationDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(
              error, 'Notification devices could not be loaded.');
        });
      }
    }
  }

  Future<void> _unregister(NotificationDevice device) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('unregisterDevice')),
        content: Text(device.tokenSuffix),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.t('unregisterDevice')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(repositoryProvider)
          .unregisterNotificationDevice(device.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.t('deviceUnregistered'))));
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The device could not be unregistered.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
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
        if (_devices.isEmpty)
          DukaanEmptyState(
            icon: Icons.devices_rounded,
            title: strings.t('noNotificationDevices'),
            detail: strings.t('notificationDevicesDetail'),
          )
        else
          for (final device in _devices)
            DukaanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const DukaanIconPlate(icon: Icons.phone_android_rounded),
                      const SizedBox(width: DukaanTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device.platform,
                                style: Theme.of(context).textTheme.titleSmall),
                            Text(device.tokenSuffix),
                          ],
                        ),
                      ),
                      DukaanBadge(
                        strings.t(
                            device.status == 'ACTIVE' ? 'active' : 'disabled'),
                        tone: device.status == 'ACTIVE'
                            ? DukaanTone.positive
                            : DukaanTone.neutral,
                      ),
                    ],
                  ),
                  if (device.lastSeenAt != null) ...[
                    const SizedBox(height: DukaanTokens.space2),
                    Text(
                      '${strings.t('lastSeen')}: '
                      '${formatDateTime(device.lastSeenAt!, locale)}',
                      style: DukaanTokens.textCaption,
                    ),
                  ],
                  if (device.status == 'ACTIVE') ...[
                    const SizedBox(height: DukaanTokens.space2),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        key: Key('device-unregister-${device.id}'),
                        onPressed:
                            online && !_busy ? () => _unregister(device) : null,
                        icon: const Icon(Icons.link_off_rounded, size: 18),
                        label: Text(strings.t('unregisterDevice')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ],
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
