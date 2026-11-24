import 'dart:typed_data';

import 'package:dukaan_ai_mobile/data/audio_recorder.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  const input = AssistantInput(
    type: AssistantInputType.text,
    content: 'Ramesh bought three shirts',
    displayText: 'Ramesh bought three shirts',
  );

  ProviderContainer voiceContainer({
    required FakeDukaanRepository repository,
    required VoiceRecorder recorder,
    required MemoryDraftStore draftStore,
    bool online = true,
  }) {
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        voiceRecorderProvider.overrideWithValue(recorder),
        draftStoreProvider.overrideWithValue(draftStore),
        networkStatusProvider.overrideWith((ref) => Stream.value(online)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('offline assistant input becomes a draft and never calls API', () async {
    final repository = FakeDukaanRepository();
    final draftStore = MemoryDraftStore();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        draftStoreProvider.overrideWithValue(draftStore),
        networkStatusProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(networkStatusProvider.future);

    await container.read(assistantControllerProvider.notifier).interpret(input);

    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.offlineDraft);
    expect(repository.interpretCalls, 0);
    final drafts = await draftStore.listDrafts(
      userId: 'user-test',
      businessId: 'business-test',
    );
    expect(drafts, hasLength(1));
    expect(drafts.single.userId, 'user-test');
    expect(drafts.single.businessId, 'business-test');
  });

  test('online proposal is read-only until explicit confirmation', () async {
    final repository = FakeDukaanRepository();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(access: 'access', refresh: 'refresh'),
        ),
        draftStoreProvider.overrideWithValue(MemoryDraftStore()),
        networkStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(networkStatusProvider.future);

    await container.read(assistantControllerProvider.notifier).interpret(input);

    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.ready);
    expect(repository.interpretCalls, 1);
    expect(repository.confirmCalls, 0);

    await container.read(assistantControllerProvider.notifier).confirm();

    expect(repository.confirmCalls, 1);
    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.saved);
  });

  test(
      'voice recording uploads multipart bytes and opens the transcribed review',
      () async {
    final repository = FakeDukaanRepository();
    final recorder = FakeVoiceRecorder(
      recording: RecordedVoice(bytes: Uint8List.fromList([10, 20, 30, 40])),
    );
    final draftStore = MemoryDraftStore();
    final container = voiceContainer(
      repository: repository,
      recorder: recorder,
      draftStore: draftStore,
    );
    await container.read(networkStatusProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);

    await controller.startVoiceRecording();
    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.recording);
    expect(recorder.startCalls, 1);

    await controller.stopVoiceRecordingAndUpload();
    final state = container.read(assistantControllerProvider);

    expect(recorder.stopCalls, 1);
    expect(repository.voiceUploadCalls, 1);
    expect(repository.presignCalls, 0);
    expect(repository.uploadedVoiceBytes, [10, 20, 30, 40]);
    expect(repository.uploadedBusinessId, 'business-test');
    expect(repository.lastFromAudioPayload, {
      'attachment_id': 'attachment-voice',
      'business_id': 'business-test',
      'location_id': 'location-test',
      'locale': 'en-IN',
    });
    expect(repository.pollCalls, 1);
    expect(state.stage, AssistantStage.ready);
    expect(state.proposal?.transcript, 'Ramesh bought three shirts');
    expect(state.input?.type, AssistantInputType.voice);
    expect(
        await draftStore.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
  });

  test('voice transcription blockers open the normal needs-details review',
      () async {
    final repository = FakeDukaanRepository()
      ..voiceProposal = AssistantProposal.fromJson({
        'id': 'proposal-voice',
        'status': 'DRAFT',
        'command_type': 'SALE',
        'content': 'Ramesh bought shirts',
        'blocking_questions': ['Which shirt did Ramesh buy?'],
        'payload': const {},
      });
    final container = voiceContainer(
      repository: repository,
      recorder: FakeVoiceRecorder(),
      draftStore: MemoryDraftStore(),
    );
    await container.read(networkStatusProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);

    await controller.startVoiceRecording();
    await controller.stopVoiceRecordingAndUpload();

    final state = container.read(assistantControllerProvider);
    expect(state.stage, AssistantStage.needsDetails);
    expect(state.proposal?.blockingQuestions, ['Which shirt did Ramesh buy?']);
    expect(repository.confirmCalls, 0);
  });

  test('offline voice recording fails clearly and never saves unusable bytes',
      () async {
    final repository = FakeDukaanRepository();
    final recorder = FakeVoiceRecorder();
    final draftStore = MemoryDraftStore();
    final container = voiceContainer(
      repository: repository,
      recorder: recorder,
      draftStore: draftStore,
      online: false,
    );
    await container.read(networkStatusProvider.future);

    await container
        .read(assistantControllerProvider.notifier)
        .startVoiceRecording();

    final state = container.read(assistantControllerProvider);
    expect(state.stage, AssistantStage.failed);
    expect(state.errorKey, 'voiceOffline');
    expect(recorder.startCalls, 0);
    expect(repository.voiceUploadCalls, 0);
    expect(
        await draftStore.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
  });

  test('microphone permission and oversized recording failures are friendly',
      () async {
    final permissionContainer = voiceContainer(
      repository: FakeDukaanRepository(),
      recorder: FakeVoiceRecorder(
        startError: const VoiceRecordingException(
            VoiceRecordingFailure.permissionDenied),
      ),
      draftStore: MemoryDraftStore(),
    );
    await permissionContainer.read(networkStatusProvider.future);
    await permissionContainer
        .read(assistantControllerProvider.notifier)
        .startVoiceRecording();
    expect(permissionContainer.read(assistantControllerProvider).errorKey,
        'microphonePermission');

    final sizeContainer = voiceContainer(
      repository: FakeDukaanRepository(),
      recorder: FakeVoiceRecorder(
        stopError:
            const VoiceRecordingException(VoiceRecordingFailure.tooLarge),
      ),
      draftStore: MemoryDraftStore(),
    );
    await sizeContainer.read(networkStatusProvider.future);
    final controller = sizeContainer.read(assistantControllerProvider.notifier);
    await controller.startVoiceRecording();
    await controller.stopVoiceRecordingAndUpload();
    expect(sizeContainer.read(assistantControllerProvider).errorKey,
        'recordingTooLarge');
  });

  test('voice upload and polling failures do not create offline drafts',
      () async {
    final uploadRepository = FakeDukaanRepository()
      ..voiceUploadError = StateError('upload failed');
    final uploadContainer = voiceContainer(
      repository: uploadRepository,
      recorder: FakeVoiceRecorder(),
      draftStore: MemoryDraftStore(),
    );
    await uploadContainer.read(networkStatusProvider.future);
    final uploadController =
        uploadContainer.read(assistantControllerProvider.notifier);
    await uploadController.startVoiceRecording();
    await uploadController.stopVoiceRecordingAndUpload();
    expect(uploadContainer.read(assistantControllerProvider).errorKey,
        'voiceUploadFailed');
    expect(uploadRepository.fromAudioCalls, 0);

    final pollRepository = FakeDukaanRepository()
      ..voicePollError = const VoiceTranscriptionException.timeout();
    final pollDraftStore = MemoryDraftStore();
    final pollContainer = voiceContainer(
      repository: pollRepository,
      recorder: FakeVoiceRecorder(),
      draftStore: pollDraftStore,
    );
    await pollContainer.read(networkStatusProvider.future);
    final pollController =
        pollContainer.read(assistantControllerProvider.notifier);
    await pollController.startVoiceRecording();
    await pollController.stopVoiceRecordingAndUpload();
    expect(pollContainer.read(assistantControllerProvider).errorKey,
        'transcriptionTimeout');
    expect(
        await pollDraftStore.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);
  });

  test('cancelling a voice recording discards capture without uploading',
      () async {
    final repository = FakeDukaanRepository();
    final recorder = FakeVoiceRecorder();
    final container = voiceContainer(
      repository: repository,
      recorder: recorder,
      draftStore: MemoryDraftStore(),
    );
    await container.read(networkStatusProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);

    await controller.startVoiceRecording();
    await controller.cancelVoiceRecording();

    expect(recorder.cancelCalls, 1);
    expect(recorder.stopCalls, 0);
    expect(repository.voiceUploadCalls, 0);
    expect(
        container.read(assistantControllerProvider).stage, AssistantStage.idle);
  });

  test('image and PDF bytes upload raw, poll OCR, and open review only',
      () async {
    final repository = FakeDukaanRepository()
      ..imageProposal = AssistantProposal.fromJson({
        'id': 'proposal-image',
        'version': 1,
        'status': 'READY',
        'command_type': 'SALE',
        'content': 'Invoice 42: two shirts',
        'preview': 'Sale from scanned receipt',
        'blocking_questions': const [],
        'payload': const {},
      });
    final draftStore = MemoryDraftStore();
    final container = voiceContainer(
      repository: repository,
      recorder: FakeVoiceRecorder(),
      draftStore: draftStore,
    );
    await container.read(networkStatusProvider.future);

    await container.read(assistantControllerProvider.notifier).interpretImage(
      bytes: [1, 2, 3, 4],
      mimeType: 'application/pdf',
      label: 'invoice.pdf',
    );

    expect(repository.imageUploadCalls, 1);
    expect(repository.uploadedImageBytes, [1, 2, 3, 4]);
    expect(repository.uploadedImageMime, 'application/pdf');
    expect(repository.uploadedBusinessId, 'business-test');
    expect(repository.lastFromImagePayload, {
      'attachment_id': 'attachment-image',
      'business_id': 'business-test',
      'location_id': 'location-test',
      'locale': 'en-IN',
    });
    expect(repository.pollCalls, 1);
    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.ready);
    expect(repository.confirmCalls, 0);
    expect(
        await draftStore.listDrafts(
          userId: 'user-test',
          businessId: 'business-test',
        ),
        isEmpty);

    await container.read(assistantControllerProvider.notifier).confirm();
    expect(repository.confirmCalls, 1);
  });

  test('offline and oversized documents fail clearly without uploading',
      () async {
    final offlineRepository = FakeDukaanRepository();
    final offlineContainer = voiceContainer(
      repository: offlineRepository,
      recorder: FakeVoiceRecorder(),
      draftStore: MemoryDraftStore(),
      online: false,
    );
    await offlineContainer.read(networkStatusProvider.future);
    await offlineContainer
        .read(assistantControllerProvider.notifier)
        .interpretImage(bytes: [1], mimeType: 'image/png', label: 'bill.png');
    expect(offlineContainer.read(assistantControllerProvider).errorKey,
        'imageOffline');
    expect(offlineRepository.imageUploadCalls, 0);

    final largeRepository = FakeDukaanRepository();
    final largeContainer = voiceContainer(
      repository: largeRepository,
      recorder: FakeVoiceRecorder(),
      draftStore: MemoryDraftStore(),
    );
    await largeContainer.read(networkStatusProvider.future);
    await largeContainer
        .read(assistantControllerProvider.notifier)
        .interpretImage(
          bytes: List<int>.filled(maxAttachmentBytes + 1, 1),
          mimeType: 'image/jpeg',
          label: 'large.jpg',
        );
    expect(largeContainer.read(assistantControllerProvider).errorKey,
        'documentTooLarge');
    expect(largeRepository.imageUploadCalls, 0);
  });

  test('cashier document review cannot confirm a purchase proposal', () async {
    final repository = FakeDukaanRepository(role: BusinessRole.cashier)
      ..imageProposal = AssistantProposal.fromJson({
        'id': 'proposal-purchase',
        'version': 1,
        'status': 'READY',
        'command_type': 'PURCHASE',
        'content': 'Bought five shirts',
        'preview': 'Purchase from supplier',
        'blocking_questions': const [],
        'payload': const {},
      });
    final container = voiceContainer(
      repository: repository,
      recorder: FakeVoiceRecorder(),
      draftStore: MemoryDraftStore(),
    );
    await container.read(bootstrapProvider.future);

    await container.read(assistantControllerProvider.notifier).interpretImage(
      bytes: [1, 2],
      mimeType: 'image/png',
      label: 'purchase.png',
    );
    expect(container.read(assistantControllerProvider).stage,
        AssistantStage.needsDetails);
    expect(container.read(assistantControllerProvider).errorKey,
        'cashierSalesOnly');

    await container.read(assistantControllerProvider.notifier).confirm();
    expect(repository.confirmCalls, 0);
  });
}
