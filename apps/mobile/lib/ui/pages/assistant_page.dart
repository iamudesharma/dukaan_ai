import 'dart:convert';
import 'dart:io';

import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
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

  @override
  void dispose() {
    _speech.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    return SafeArea(
      top: false,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (state.stage) {
          AssistantStage.parsing || AssistantStage.confirming =>
            _WorkingState(confirming: state.stage == AssistantStage.confirming),
          AssistantStage.ready || AssistantStage.needsDetails => _ProposalState(
              state: state,
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
              message: state.error,
              onRetry: state.input == null
                  ? _reset
                  : ref.read(assistantControllerProvider.notifier).retry,
              onEdit: _editRequest,
            ),
          _ => _CaptureState(
              controller: _controller,
              listening: state.stage == AssistantStage.listening,
              onSubmit: _submitText,
              onListen: _toggleListening,
              onScan: _scanBill,
              onUpload: _uploadBill,
              onExample: _useExample,
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
      if (mounted) _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  Future<void> _submitText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(assistantControllerProvider.notifier).interpret(
          AssistantInput(type: _typedInputType, content: text, displayText: text),
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

  Future<void> _toggleListening() async {
    final notifier = ref.read(assistantControllerProvider.notifier);
    final localeId = Localizations.localeOf(context).languageCode == 'hi' ? 'hi_IN' : 'en_IN';
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
        if (status == SpeechToText.doneStatus && mounted) notifier.setListening(false);
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
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
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
      await _interpretFile(
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
      final bytes = file.bytes ?? (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null || bytes.length > 8 * 1024 * 1024) {
        if (mounted) _showMessage(context.strings.t('captureFailed'));
        return;
      }
      final extension = (file.extension ?? '').toLowerCase();
      final mime = extension == 'pdf'
          ? 'application/pdf'
          : extension == 'png'
              ? 'image/png'
              : 'image/jpeg';
      await _interpretFile(bytes: bytes, mimeType: mime, label: file.name);
    } on Object {
      if (mounted) _showMessage(context.strings.t('captureFailed'));
    }
  }

  Future<void> _interpretFile({
    required List<int> bytes,
    required String mimeType,
    required String label,
  }) {
    return ref.read(assistantControllerProvider.notifier).interpret(
          AssistantInput(
            type: AssistantInputType.image,
            content: 'data:$mimeType;base64,${base64Encode(bytes)}',
            displayText: label,
          ),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CaptureState extends StatelessWidget {
  const _CaptureState({
    required this.controller,
    required this.listening,
    required this.onSubmit,
    required this.onListen,
    required this.onScan,
    required this.onUpload,
    required this.onExample,
  });

  final TextEditingController controller;
  final bool listening;
  final VoidCallback onSubmit;
  final VoidCallback onListen;
  final VoidCallback onScan;
  final VoidCallback onUpload;
  final VoidCallback onExample;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return ListView(
      key: const ValueKey('capture'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 10),
        Text(
          strings.t('assistantPrompt'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          strings.t('assistantExample'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
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
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _CaptureButton(
              icon: listening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
              label: listening ? strings.t('stopListening') : strings.t('speak'),
              selected: listening,
              onPressed: onListen,
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
        if (listening) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.graphic_eq_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  strings.t('listening'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const Key('assistant-submit'),
          onPressed: onSubmit,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(strings.t('reviewTitle')),
        ),
        TextButton(onPressed: onExample, child: Text(strings.t('tryExample'))),
        const SizedBox(height: 18),
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
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
}

class _WorkingState extends StatelessWidget {
  const _WorkingState({required this.confirming});

  final bool confirming;

  @override
  Widget build(BuildContext context) => Center(
        key: const ValueKey('working'),
        child: Semantics(
          liveRegion: true,
          label: confirming ? context.strings.t('confirm') : context.strings.t('parsing'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 18),
              Text(
                confirming ? context.strings.t('confirm') : context.strings.t('parsing'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
}

class _ProposalState extends StatefulWidget {
  const _ProposalState({
    required this.state,
    required this.onConfirm,
    required this.onEdit,
    required this.onAddDetails,
  });

  final AssistantState state;
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
    return ListView(
      key: const ValueKey('proposal'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          context.strings.t('reviewTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(context.strings.t('reviewDetail')),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                ...proposal.facts.map(
                  (fact) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(fact.label)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            fact.value,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: fact.warning ? Theme.of(context).colorScheme.error : null,
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
        ),
        if (proposal.warnings.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...proposal.warnings.map(
            (warning) => Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(warning),
              ),
            ),
          ),
        ],
        if (proposal.blockingQuestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            context.strings.t('couldNotUnderstand'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...proposal.blockingQuestions.map((question) => Text('• $question')),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: context.strings.t('type')),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              if (_details.text.trim().isNotEmpty) widget.onAddDetails(_details.text.trim());
            },
            child: Text(context.strings.t('reviewTitle')),
          ),
        ] else ...[
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('proposal-confirm'),
            onPressed: widget.onConfirm,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(context.strings.t('confirm')),
          ),
        ],
        const SizedBox(height: 6),
        TextButton(onPressed: widget.onEdit, child: Text(context.strings.t('editRequest'))),
      ],
    );
  }
}

class _SavedState extends StatelessWidget {
  const _SavedState({required this.result, required this.onAnother, required this.onEntries});

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
  const _FailedState({required this.message, required this.onRetry, required this.onEdit});

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
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: color),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(detail, textAlign: TextAlign.center),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                ),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              ],
            ),
          ),
        ),
      );
}

class _NoMoneyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(context.strings.t('noMoneyMovement'))),
            ],
          ),
        ),
      );
}
