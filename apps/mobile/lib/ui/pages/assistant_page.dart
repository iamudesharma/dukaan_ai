import 'dart:async';
import 'dart:io';

import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  final _imagePicker = ImagePicker();
  AssistantInputType _typedInputType = AssistantInputType.text;
  late final AssistantController _assistantController;

  @override
  void initState() {
    super.initState();
    _assistantController = ref.read(assistantControllerProvider.notifier);
  }

  @override
  void dispose() {
    if (_assistantController.currentStage == AssistantStage.recording) {
      unawaited(_assistantController.cancelVoiceRecording());
    }
    _speech.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    final role = ref.watch(currentBusinessRoleProvider);
    return SafeArea(
      top: false,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (state.stage) {
          AssistantStage.recording => _RecordingState(
              duration: state.recordingDuration,
              onStop: ref
                  .read(assistantControllerProvider.notifier)
                  .stopVoiceRecordingAndUpload,
              onCancel: ref
                  .read(assistantControllerProvider.notifier)
                  .cancelVoiceRecording,
            ),
          AssistantStage.parsing ||
          AssistantStage.transcribing ||
          AssistantStage.processingDocument ||
          AssistantStage.confirming =>
            _WorkingState(stage: state.stage),
          AssistantStage.ready || AssistantStage.needsDetails => _ProposalState(
              state: state,
              canConfirm: state.proposal?.canConfirm == true &&
                  state.proposal!.canBeRecordedBy(role),
              onConfirm: ref.read(assistantControllerProvider.notifier).confirm,
              onEdit: _editRequest,
              onAddDetails: (details) => _addDetails(state, details),
            ),
          AssistantStage.saved => _SavedState(
              result: state.result!,
              onAnother: _reset,
              onEntries: () => context.go('/entries'),
            ),
          AssistantStage.offlineDraft => _OfflineDraftState(onAnother: _reset),
          AssistantStage.failed => _FailedState(
              message: state.error ??
                  context.strings.t(state.errorKey ?? 'loadFailed'),
              onRetry: state.input == null
                  ? _reset
                  : ref.read(assistantControllerProvider.notifier).retry,
              onEdit: _editRequest,
            ),
          _ => _CaptureState(
              controller: _controller,
              listening: state.stage == AssistantStage.listening,
              onSubmit: _submitText,
              onRecord: _toggleVoiceRecording,
              onDeviceSpeech: _toggleListening,
              onScan: _scanBill,
              onUpload: _uploadBill,
              onExample: _useExample,
              salesOnly: !role.canManageOperations,
            ),
        },
      ),
    );
  }

  void _reset() {
    _controller.clear();
    _typedInputType = AssistantInputType.text;
    ref.read(assistantControllerProvider.notifier).reset();
  }

  void _editRequest() {
    ref.read(assistantControllerProvider.notifier).reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
      }
    });
  }

  Future<void> _submitText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(assistantControllerProvider.notifier).interpret(
          AssistantInput(
              type: _typedInputType, content: text, displayText: text),
        );
  }

  Future<void> _addDetails(AssistantState state, String details) async {
    final original = state.input?.content ?? '';
    _controller.text = '$original $details'.trim();
    _typedInputType = AssistantInputType.text;
    await _submitText();
  }

  void _useExample() {
    _controller.text = Localizations.localeOf(context).languageCode == 'hi'
        ? 'रमेश ने 3 शर्ट ₹2400 में लीं, ₹1500 दिए और ₹900 बाकी है'
        : 'Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending';
    _typedInputType = AssistantInputType.text;
  }

  Future<void> _toggleVoiceRecording() {
    final controller = ref.read(assistantControllerProvider.notifier);
    if (ref.read(assistantControllerProvider).stage ==
        AssistantStage.recording) {
      return controller.stopVoiceRecordingAndUpload();
    }
    return controller.startVoiceRecording();
  }

  Future<void> _toggleListening() async {
    final notifier = ref.read(assistantControllerProvider.notifier);
    final localeId = Localizations.localeOf(context).languageCode == 'hi'
        ? 'hi_IN'
        : 'en_IN';
    if (_speech.isListening) {
      await _speech.stop();
      notifier.setListening(false);
      return;
    }
    final available = await _speech.initialize(
      onError: (_) {
        if (mounted) notifier.setListening(false);
      },
      onStatus: (status) {
        if (status == SpeechToText.doneStatus && mounted) {
          notifier.setListening(false);
        }
      },
    );
    if (!available) {
      if (mounted) _showMessage(context.strings.t('voiceUnavailable'));
      return;
    }
    _typedInputType = AssistantInputType.voice;
    notifier.setListening(true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
        if (result.finalResult) notifier.setListening(false);
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _scanBill() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await _interpretDocument(
        bytes: bytes,
        mimeType: 'image/jpeg',
        label: 'Photo: ${file.name}',
      );
    } on Object {
      if (mounted) _showMessage(context.strings.t('captureFailed'));
    }
  }

  Future<void> _uploadBill() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      final file = result?.files.single;
      if (file == null) return;
      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null) {
        if (mounted) _showMessage(context.strings.t('captureFailed'));
        return;
      }
      if (bytes.length > maxAttachmentBytes) {
        if (mounted) _showMessage(context.strings.t('documentTooLarge'));
        return;
      }
      final extension = (file.extension ?? '').toLowerCase();
      final mime = extension == 'pdf'
          ? 'application/pdf'
          : extension == 'png'
              ? 'image/png'
              : 'image/jpeg';
      await _interpretDocument(bytes: bytes, mimeType: mime, label: file.name);
    } on Object {
      if (mounted) _showMessage(context.strings.t('captureFailed'));
    }
  }

  Future<void> _interpretDocument({
    required List<int> bytes,
    required String mimeType,
    required String label,
  }) {
    return ref.read(assistantControllerProvider.notifier).interpretImage(
          bytes: bytes,
          mimeType: mimeType,
          label: label,
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CaptureState extends StatelessWidget {
  const _CaptureState({
    required this.controller,
    required this.listening,
    required this.onSubmit,
    required this.onRecord,
    required this.onDeviceSpeech,
    required this.onScan,
    required this.onUpload,
    required this.onExample,
    this.salesOnly = false,
  });

  final TextEditingController controller;
  final bool listening;
  final VoidCallback onSubmit;
  final VoidCallback onRecord;
  final VoidCallback onDeviceSpeech;
  final VoidCallback onScan;
  final VoidCallback onUpload;
  final VoidCallback onExample;
  final bool salesOnly;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      key: const ValueKey('capture'),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space5,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker('01 · ${strings.t('ask')}'),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          strings.t('assistantPrompt'),
          textAlign: TextAlign.center,
          style: DukaanTokens.textTitle.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space2),
        Text(
          strings.t('assistantExample'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: DukaanTokens.space5),
        TextField(
          key: const Key('assistant-input'),
          controller: controller,
          minLines: 4,
          maxLines: 7,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: strings.t('type'),
            alignLabelWithHint: true,
            hintText: strings.t('assistantExample'),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: DukaanTokens.space3),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: DukaanTokens.space2,
          runSpacing: DukaanTokens.space2,
          children: [
            _CaptureButton(
              key: const Key('assistant-record'),
              icon: Icons.mic_none_rounded,
              label: strings.t('recordVoice'),
              onPressed: onRecord,
            ),
            _CaptureButton(
              icon: Icons.document_scanner_outlined,
              label: strings.t('scanBill'),
              onPressed: onScan,
            ),
            _CaptureButton(
              icon: Icons.upload_file_outlined,
              label: strings.t('upload'),
              onPressed: onUpload,
            ),
          ],
        ),
        if (salesOnly) ...[
          const SizedBox(height: DukaanTokens.space2),
          Text(
            strings.t('cashierScanHint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: DukaanTokens.space2),
        TextButton.icon(
          key: const Key('assistant-device-speech'),
          onPressed: onDeviceSpeech,
          icon: Icon(
            listening
                ? Icons.stop_circle_outlined
                : Icons.record_voice_over_outlined,
            size: 18,
          ),
          label: Text(
            listening
                ? strings.t('stopListening')
                : strings.t('deviceSpeechFallback'),
          ),
        ),
        if (listening) ...[
          const SizedBox(height: DukaanTokens.space3),
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.graphic_eq_rounded,
                  color: DukaanTokens.colorPrimary,
                  size: 20,
                ),
                const SizedBox(width: DukaanTokens.space2),
                Text(strings.t('listening'), style: DukaanTokens.textLabel),
              ],
            ),
          ),
        ],
        const SizedBox(height: DukaanTokens.space5),
        FilledButton.icon(
          key: const Key('assistant-submit'),
          onPressed: onSubmit,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(strings.t('reviewTitle')),
        ),
        TextButton(onPressed: onExample, child: Text(strings.t('tryExample'))),
        const SizedBox(height: DukaanTokens.space5),
        _NoMoneyCard(),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
}

class _RecordingState extends StatelessWidget {
  const _RecordingState({
    required this.duration,
    required this.onStop,
    required this.onCancel,
  });

  final Duration duration;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return Center(
      key: const ValueKey('recording'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DukaanTokens.space6),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 34,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: DukaanTokens.space4),
              Text(
                strings.t('recording'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DukaanTokens.space2),
              Text(
                '$minutes:$seconds',
                style: DukaanTokens.textAmountLarge,
              ),
              const SizedBox(height: DukaanTokens.space2),
              Text(
                strings.t('recordingHint'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: DukaanTokens.space5),
              FilledButton.icon(
                key: const Key('assistant-stop-recording'),
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded, size: 18),
                label: Text(strings.t('stopRecording')),
              ),
              TextButton(
                key: const Key('assistant-cancel-recording'),
                onPressed: onCancel,
                child: Text(strings.t('cancelRecording')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkingState extends StatelessWidget {
  const _WorkingState({required this.stage});

  final AssistantStage stage;

  @override
  Widget build(BuildContext context) {
    final label = context.strings.t(switch (stage) {
      AssistantStage.transcribing => 'transcribing',
      AssistantStage.processingDocument => 'scanningDocument',
      AssistantStage.confirming => 'confirm',
      _ => 'parsing',
    });
    return Center(
      key: const ValueKey('working'),
      child: Semantics(
        liveRegion: true,
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: DukaanTokens.space4),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalState extends StatefulWidget {
  const _ProposalState({
    required this.state,
    required this.canConfirm,
    required this.onConfirm,
    required this.onEdit,
    required this.onAddDetails,
  });

  final AssistantState state;
  final bool canConfirm;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final ValueChanged<String> onAddDetails;

  @override
  State<_ProposalState> createState() => _ProposalStateState();
}

class _ProposalStateState extends State<_ProposalState> {
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proposal = widget.state.proposal!;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      key: const ValueKey('proposal'),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space5,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker('02 · ${context.strings.t('ask')}'),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('reviewTitle'),
          style: DukaanTokens.textTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('reviewDetail'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        DukaanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(proposal.title, style: DukaanTokens.textHeading),
              const SizedBox(height: DukaanTokens.space3),
              ...proposal.facts.map(
                (fact) => Padding(
                  padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          fact.label,
                          style: DukaanTokens.textLabel.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: DukaanTokens.space3),
                      Flexible(
                        child: Text(
                          fact.value,
                          textAlign: TextAlign.end,
                          style: DukaanTokens.textAmount.copyWith(
                            color: fact.warning
                                ? scheme.onTertiaryContainer
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (proposal.warnings.isNotEmpty) ...[
          const SizedBox(height: DukaanTokens.space3),
          ...proposal.warnings.map(
            (warning) => Padding(
              padding: const EdgeInsets.only(bottom: DukaanTokens.space2),
              child: Container(
                padding: const EdgeInsets.all(DukaanTokens.space3),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius:
                      BorderRadius.circular(DukaanTokens.radiusControl),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 17,
                      color: DukaanTokens.colorAttentionInk,
                    ),
                    const SizedBox(width: DukaanTokens.space2),
                    Expanded(
                      child: Text(
                        warning,
                        style: DukaanTokens.textLabel.copyWith(
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (proposal.blockingQuestions.isNotEmpty) ...[
          const SizedBox(height: DukaanTokens.space3),
          Text(
            context.strings.t('couldNotUnderstand'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: DukaanTokens.space2),
          ...proposal.blockingQuestions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: DukaanTokens.space1),
              child: Text(
                '• $question',
                style: DukaanTokens.textLabel.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextField(
            controller: _details,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: context.strings.t('type')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          FilledButton(
            onPressed: () {
              if (_details.text.trim().isNotEmpty) {
                widget.onAddDetails(_details.text.trim());
              }
            },
            child: Text(context.strings.t('reviewTitle')),
          ),
        ] else if (!widget.canConfirm) ...[
          const SizedBox(height: DukaanTokens.space3),
          Container(
            padding: const EdgeInsets.all(DukaanTokens.space3),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 17),
                const SizedBox(width: DukaanTokens.space2),
                Expanded(
                  child: Text(
                    widget.state.errorKey == 'cashierSalesOnly'
                        ? context.strings.t('cashierSalesOnly')
                        : context.strings.t('proposalNotReady'),
                    style: DukaanTokens.textLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space4),
        ] else ...[
          const SizedBox(height: DukaanTokens.space5),
          FilledButton.icon(
            key: const Key('proposal-confirm'),
            onPressed: widget.onConfirm,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(context.strings.t('confirm')),
          ),
        ],
        const SizedBox(height: DukaanTokens.space1),
        TextButton(
            onPressed: widget.onEdit,
            child: Text(context.strings.t('editRequest'))),
      ],
    );
  }
}

class _SavedState extends StatelessWidget {
  const _SavedState(
      {required this.result, required this.onAnother, required this.onEntries});

  final PostedResult result;
  final VoidCallback onAnother;
  final VoidCallback onEntries;

  @override
  Widget build(BuildContext context) => _CenteredStatus(
        key: const ValueKey('saved'),
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.primary,
        title: context.strings.t('saved'),
        detail: '${context.strings.t('savedDetail')}\n${result.reference}',
        primaryLabel: context.strings.t('backToEntries'),
        onPrimary: onEntries,
        secondaryLabel: context.strings.t('ask'),
        onSecondary: onAnother,
      );
}

class _OfflineDraftState extends StatelessWidget {
  const _OfflineDraftState({required this.onAnother});

  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) => _CenteredStatus(
        key: const ValueKey('offline-draft'),
        icon: Icons.edit_note_rounded,
        color: Theme.of(context).colorScheme.secondary,
        title: context.strings.t('draftSaved'),
        detail: context.strings.t('draftSavedDetail'),
        primaryLabel: context.strings.t('backToEntries'),
        onPrimary: () => context.go('/entries'),
        secondaryLabel: context.strings.t('ask'),
        onSecondary: onAnother,
      );
}

class _FailedState extends StatelessWidget {
  const _FailedState(
      {required this.message, required this.onRetry, required this.onEdit});

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _CenteredStatus(
        key: const ValueKey('failed'),
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        title: context.strings.t('loadFailed'),
        detail: message ?? context.strings.t('loadFailed'),
        primaryLabel: context.strings.t('retry'),
        onPrimary: onRetry,
        secondaryLabel: context.strings.t('editRequest'),
        onSecondary: onEdit,
      );
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DukaanTokens.space6),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: DukaanTokens.colorOnPrimary),
              ),
              const SizedBox(height: DukaanTokens.space4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DukaanTokens.space2),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: DukaanTokens.space5),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: onPrimary, child: Text(primaryLabel)),
              ),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoMoneyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DukaanCard(
        padding: const EdgeInsets.all(DukaanTokens.space4),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: DukaanTokens.space3),
            Expanded(
              child: Text(
                context.strings.t('noMoneyMovement'),
                style: DukaanTokens.textCaption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
}
