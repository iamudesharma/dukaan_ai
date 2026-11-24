import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/api_client.dart';
import 'package:dukaan_ai_mobile/data/audio_recorder.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final draftStoreProvider = Provider<DraftStore>(
  (ref) => throw StateError('DraftStore must be overridden at the app root.'),
);

final sessionStoreProvider =
    Provider<SessionStore>((ref) => SecureSessionStore());

final dioProvider = Provider<Dio>(
  (ref) => createDio(ref.watch(sessionStoreProvider)),
);

final repositoryProvider = Provider<DukaanRepository>(
  (ref) => ApiDukaanRepository(ref.watch(dioProvider)),
);

/// The signed-in identity comes from GET /me/. A minimal cached id is used only
/// when the network is unavailable, so cold-start offline review stays scoped.
final currentUserProvider = FutureProvider<CurrentUser>((ref) async {
  final store = ref.watch(sessionStoreProvider);
  try {
    final user = CurrentUser.fromJson(
      await ref.watch(repositoryProvider).fetchMe(),
    );
    if (user.id.isEmpty) throw const FormatException('Missing user id.');
    try {
      await store.writeCachedUserId(user.id);
    } on Object {
      // Identity caching is a convenience, not a reason to reject a valid /me/.
    }
    return user;
  } on Object {
    final token = await store.readAccessToken();
    final cachedId =
        token == null || token.isEmpty ? null : await store.readCachedUserId();
    if (cachedId == null || cachedId.isEmpty) rethrow;
    return CurrentUser(id: cachedId);
  }
});

/// Role and active business are server-provided bootstrap facts. Unknown or
/// unavailable roles fail closed in currentBusinessRoleProvider.
final bootstrapProvider = FutureProvider<BusinessBootstrap>((ref) async {
  final store = ref.watch(sessionStoreProvider);
  try {
    final raw = await ref.watch(repositoryProvider).fetchBootstrap();
    final bootstrap = BusinessBootstrap.fromJson(raw);
    if (bootstrap.businessId.isEmpty) {
      throw const FormatException('Missing business id.');
    }
    try {
      await store.writeCachedBootstrap(raw);
    } on Object {
      // As above, a cache write must not invalidate a successful bootstrap.
    }
    return bootstrap;
  } on Object {
    final token = await store.readAccessToken();
    final cached = token == null || token.isEmpty
        ? null
        : await store.readCachedBootstrap();
    if (cached != null) {
      final bootstrap = BusinessBootstrap.fromJson(cached);
      if (bootstrap.businessId.isNotEmpty) return bootstrap;
    }
    rethrow;
  }
});

final currentBusinessRoleProvider = Provider<BusinessRole>(
  (ref) =>
      ref.watch(bootstrapProvider).valueOrNull?.role ?? BusinessRole.cashier,
);

@immutable
class DraftScope {
  const DraftScope({required this.userId, required this.businessId});

  final String userId;
  final String businessId;
}

bool _canRecordProposal(BusinessRole role, AssistantProposal proposal) =>
    proposal.canBeRecordedBy(role);

final currentDraftScopeProvider = FutureProvider<DraftScope>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  final bootstrap = await ref.watch(bootstrapProvider.future);
  if (user.id.isEmpty || bootstrap.businessId.isEmpty) {
    throw StateError('The signed-in user and business must be known.');
  }
  return DraftScope(userId: user.id, businessId: bootstrap.businessId);
});

final voiceRecorderProvider = Provider<VoiceRecorder>((ref) {
  final recorder = RecordVoiceRecorder();
  ref.onDispose(() {
    recorder.dispose();
  });
  return recorder;
});

final networkStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _hasNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasNetwork).distinct();
});

bool _hasNetwork(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

final localeProvider = StateNotifierProvider<AppLocaleController, Locale>(
  (ref) => AppLocaleController(),
);

class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController() : super(const Locale('en'));

  void toggle() {
    state =
        state.languageCode == 'en' ? const Locale('hi') : const Locale('en');
  }
}

final selectedLocationIdProvider = StateProvider<String?>((ref) => null);

final locationsProvider = FutureProvider<List<BusinessLocation>>(
  (ref) => ref.watch(repositoryProvider).fetchLocations(),
);

final activeLocationProvider = FutureProvider<BusinessLocation>((ref) async {
  final selectedId = ref.watch(selectedLocationIdProvider);
  final locations = await ref.watch(locationsProvider.future);
  if (locations.isEmpty) throw StateError('No business location is available.');
  if (selectedId == null) {
    return locations.firstWhere(
      (location) => location.isPrimary,
      orElse: () => locations.first,
    );
  }
  return locations.firstWhere(
    (location) => location.id == selectedId,
    orElse: () => locations.first,
  );
});

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchDashboard(location.id);
});

final entriesProvider = FutureProvider<List<BusinessEntry>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  final role = ref.watch(currentBusinessRoleProvider);
  return ref.watch(repositoryProvider).fetchEntries(location.id, role: role);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchProducts(location.id);
});

final partiesProvider = FutureProvider<List<Party>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchParties(location.id);
});

final localDraftsProvider = FutureProvider<List<LocalDraft>>((ref) async {
  final scope = await ref.watch(currentDraftScopeProvider.future);
  return ref.watch(draftStoreProvider).listDrafts(
        userId: scope.userId,
        businessId: scope.businessId,
      );
});

Future<LocalDraft> saveScopedDraft(
  Ref ref, {
  required DraftKind kind,
  required BusinessLocation location,
  required String label,
  required Map<String, dynamic> payload,
  String? id,
  DateTime? createdAt,
}) async {
  final scope = await ref.read(currentDraftScopeProvider.future);
  if (scope.businessId != location.businessId) {
    throw StateError('A draft cannot be saved outside the active business.');
  }
  final draft = LocalDraft(
    id: id ?? const Uuid().v4(),
    kind: kind,
    userId: scope.userId,
    businessId: scope.businessId,
    locationId: location.id,
    label: label,
    payload: payload,
    createdAt: createdAt ?? DateTime.now(),
  );
  await ref.read(draftStoreProvider).saveDraft(draft);
  ref.invalidate(localDraftsProvider);
  return draft;
}

void invalidateBusinessData(Ref ref) {
  ref
    ..invalidate(dashboardProvider)
    ..invalidate(entriesProvider)
    ..invalidate(productsProvider)
    ..invalidate(partiesProvider);
}

/// Clears every account-specific cache when credentials change. In particular,
/// ApiDukaanRepository caches a business id, so it must not survive sign-out.
void invalidateSessionScopedProviders(Ref ref) {
  ref.read(selectedLocationIdProvider.notifier).state = null;
  ref
    ..invalidate(repositoryProvider)
    ..invalidate(currentUserProvider)
    ..invalidate(bootstrapProvider)
    ..invalidate(locationsProvider)
    ..invalidate(localDraftsProvider)
    ..invalidate(draftSyncProvider)
    ..invalidate(assistantControllerProvider);
  invalidateBusinessData(ref);
}

/// Result of one explicit draft send. Nothing in this controller sends in bulk
/// or as a reaction to connectivity changes.
typedef DraftSendResult = ({bool synced, String? error});

typedef DraftReviewResult = ({
  AssistantProposal? proposal,
  String? error,
});

typedef DraftConfirmationResult = ({
  bool synced,
  String? error,
  AssistantProposal? refreshedProposal,
  PostedResult? postedResult,
});

@immutable
class DraftSyncState {
  const DraftSyncState({
    this.busy = false,
    this.synced = 0,
    this.failed = 0,
    this.errors = const {},
  });

  final bool busy;
  final int synced;
  final int failed;
  final Map<String, String> errors;
}

final draftSyncProvider =
    StateNotifierProvider<DraftSyncController, DraftSyncState>(
  (ref) => DraftSyncController(ref),
);

/// Drafts are review-only. Review may interpret an assistant request, but only
/// the dedicated confirmation and per-sale send methods can write to the API.
class DraftSyncController extends StateNotifier<DraftSyncState> {
  DraftSyncController(this._ref) : super(const DraftSyncState());

  final Ref _ref;

  Future<DraftReviewResult> reviewAssistantDraft(LocalDraft draft) async {
    if (state.busy) {
      return (proposal: null, error: 'Another draft action is in progress.');
    }
    state = const DraftSyncState(busy: true);
    try {
      final scope = await _currentScope();
      final stored = await _loadScopedDraft(draft, scope);
      final payload = Map<String, dynamic>.from(stored.payload);
      final storedProposal = payload['proposal'];
      if (storedProposal is Map) {
        final proposal = AssistantProposal.fromJson(
          Map<String, dynamic>.from(storedProposal),
        );
        state = const DraftSyncState();
        return (proposal: proposal, error: null);
      }

      final inputMap = payload['input'];
      if (inputMap is! Map) {
        throw StateError('This draft is missing its details.');
      }
      if (!await _online()) {
        throw StateError('Reconnect to prepare this draft for review.');
      }
      final proposal = await _ref.read(repositoryProvider).interpret(
            input: AssistantInput.fromJson(Map<String, dynamic>.from(inputMap)),
            locationId: stored.locationId,
            locale: _ref.read(localeProvider).languageCode,
          );
      await _ref.read(draftStoreProvider).saveDraft(
            LocalDraft(
              id: stored.id,
              kind: stored.kind,
              userId: stored.userId,
              businessId: stored.businessId,
              locationId: stored.locationId,
              label: stored.label,
              payload: {...payload, 'proposal': proposal.toJson()},
              createdAt: stored.createdAt,
            ),
          );
      _ref.invalidate(localDraftsProvider);
      state = const DraftSyncState();
      return (proposal: proposal, error: null);
    } on Object catch (error) {
      final message = _friendlyError(error);
      state = DraftSyncState(failed: 1, errors: {draft.id: message});
      return (proposal: null, error: message);
    }
  }

  Future<DraftConfirmationResult> confirmAssistantDraft(
    LocalDraft draft,
    AssistantProposal proposal,
  ) async {
    if (state.busy) {
      return (
        synced: false,
        error: 'Another draft action is in progress.',
        refreshedProposal: null,
        postedResult: null,
      );
    }
    state = const DraftSyncState(busy: true);
    try {
      final scope = await _currentScope();
      final stored = await _loadScopedDraft(draft, scope);
      if (stored.kind != DraftKind.assistant) {
        throw StateError('This is not an assistant draft.');
      }
      if (!proposal.canConfirm ||
          !_canRecordProposal(
            _ref.read(currentBusinessRoleProvider),
            proposal,
          )) {
        throw StateError(
            'This proposal needs review before it can be recorded.');
      }
      if (!await _online()) {
        throw StateError('Reconnect before confirming this draft.');
      }
      final payload = Map<String, dynamic>.from(stored.payload);
      final storedProposal = payload['proposal'];
      if (storedProposal is! Map ||
          storedProposal['id']?.toString() != proposal.id) {
        throw StateError('Review this draft again before confirming.');
      }

      final repository = _ref.read(repositoryProvider);
      PostedResult postedResult;
      try {
        postedResult = await repository.confirmProposal(proposal);
      } on DioException catch (error) {
        if (!_isStaleProposal(error)) rethrow;
        final refreshed = await repository.refreshProposal(proposal);
        await _ref.read(draftStoreProvider).saveDraft(
              LocalDraft(
                id: stored.id,
                kind: stored.kind,
                userId: stored.userId,
                businessId: stored.businessId,
                locationId: stored.locationId,
                label: stored.label,
                payload: {...payload, 'proposal': refreshed.toJson()},
                createdAt: stored.createdAt,
              ),
            );
        _ref.invalidate(localDraftsProvider);
        state = const DraftSyncState();
        // Never confirm refreshed data without another explicit human action.
        return (
          synced: false,
          error:
              'Details changed. Review the updated proposal before recording.',
          refreshedProposal: refreshed,
          postedResult: null,
        );
      }

      await _deleteScopedDraft(stored, scope);
      invalidateBusinessData(_ref);
      state = const DraftSyncState(synced: 1);
      return (
        synced: true,
        error: null,
        refreshedProposal: null,
        postedResult: postedResult,
      );
    } on Object catch (error) {
      final message = _friendlyError(error);
      state = DraftSyncState(failed: 1, errors: {draft.id: message});
      return (
        synced: false,
        error: message,
        refreshedProposal: null,
        postedResult: null,
      );
    }
  }

  /// The only sale-draft posting path. It always requires one identified draft
  /// and a fresh scope check; there is deliberately no sync-all method.
  Future<DraftSendResult> sendSaleDraft(LocalDraft draft) async {
    if (state.busy) {
      return (synced: false, error: 'Another draft action is in progress.');
    }
    state = const DraftSyncState(busy: true);
    try {
      final scope = await _currentScope();
      final stored = await _loadScopedDraft(draft, scope);
      if (stored.kind != DraftKind.sale) {
        throw StateError('Only sale drafts can be sent from this action.');
      }
      if (!await _online()) {
        throw StateError('Reconnect before sending this sale.');
      }
      final sale = SaleDraft.fromLocalJson(
        Map<String, dynamic>.from(stored.payload),
      );
      if (sale.businessId != scope.businessId ||
          sale.locationId != stored.locationId) {
        throw StateError('This sale does not belong to the active business.');
      }
      if (!_ref
          .read(currentBusinessRoleProvider)
          .canUsePriceMode(sale.priceMode)) {
        throw StateError('Cashiers can send retail sales only.');
      }
      await _ref.read(repositoryProvider).createSale(
            sale,
            idempotencyKey: 'draft:${stored.id}',
          );
      await _deleteScopedDraft(stored, scope);
      invalidateBusinessData(_ref);
      state = const DraftSyncState(synced: 1);
      return (synced: true, error: null);
    } on Object catch (error) {
      final message = _friendlyError(error);
      state = DraftSyncState(failed: 1, errors: {draft.id: message});
      return (synced: false, error: message);
    }
  }

  /// Explicit per-draft posting for purchase, expense, receipt/payment, and
  /// transfer forms. There is intentionally no bulk or connectivity-triggered
  /// send path.
  Future<DraftSendResult> sendOperationDraft(LocalDraft draft) async {
    if (state.busy) {
      return (synced: false, error: 'Another draft action is in progress.');
    }
    state = const DraftSyncState(busy: true);
    try {
      final scope = await _currentScope();
      final stored = await _loadScopedDraft(draft, scope);
      final operation = OperationDraft.fromLocalJson(stored.payload);
      if (operation.kind.draftKind != stored.kind) {
        throw StateError('This draft does not match its operation type.');
      }
      if (!operation.canBeRecordedBy(_ref.read(currentBusinessRoleProvider))) {
        throw StateError(
            'Your current role cannot send this operation. Cashiers can send receipts only.');
      }
      if (!await _online()) {
        throw StateError('Reconnect before sending this draft.');
      }
      if (operation.businessId != scope.businessId ||
          operation.locationId != stored.locationId ||
          operation.businessId.isEmpty ||
          operation.locationId.isEmpty) {
        throw StateError(
            'This operation does not belong to the active business location.');
      }

      final repository = _ref.read(repositoryProvider);
      final payload = operation.toApiJson('draft:${stored.id}');
      switch (operation.kind) {
        case OperationKind.purchase:
          await repository.createPurchase(payload);
        case OperationKind.expense:
          await repository.createExpense(payload);
        case OperationKind.payment:
          await repository.createPayment(payload);
        case OperationKind.transfer:
          await repository.createTransfer(payload);
      }
      await _deleteScopedDraft(stored, scope);
      invalidateBusinessData(_ref);
      state = const DraftSyncState(synced: 1);
      return (synced: true, error: null);
    } on Object catch (error) {
      final message = _friendlyError(error);
      state = DraftSyncState(failed: 1, errors: {draft.id: message});
      return (synced: false, error: message);
    }
  }

  Future<void> discardDraft(LocalDraft draft) async {
    final scope = await _currentScope();
    final stored = await _loadScopedDraft(draft, scope);
    await _deleteScopedDraft(stored, scope);
  }

  Future<LocalDraft> _loadScopedDraft(
    LocalDraft candidate,
    DraftScope scope,
  ) async {
    if (!candidate.belongsTo(
      userId: scope.userId,
      businessId: scope.businessId,
    )) {
      throw StateError('This draft is not available for this account.');
    }
    final drafts = await _ref.read(draftStoreProvider).listDrafts(
          userId: scope.userId,
          businessId: scope.businessId,
        );
    for (final draft in drafts) {
      if (draft.id == candidate.id) return draft;
    }
    throw StateError('This draft is no longer available for this account.');
  }

  Future<void> _deleteScopedDraft(LocalDraft draft, DraftScope scope) async {
    await _ref.read(draftStoreProvider).deleteDraft(
          draft.id,
          userId: scope.userId,
          businessId: scope.businessId,
        );
    _ref.invalidate(localDraftsProvider);
  }

  Future<DraftScope> _currentScope() =>
      _ref.read(currentDraftScopeProvider.future);

  bool _isStaleProposal(DioException error) {
    final data = error.response?.data;
    final detail = data is Map ? data['error'] : null;
    final body = detail is Map ? detail['detail'] : null;
    return body is Map && body['code'] == 'stale_proposal_data';
  }

  Future<bool> _online() async {
    try {
      return await _ref.read(networkStatusProvider.future);
    } on Object {
      return false;
    }
  }

  String _friendlyError(Object error) {
    if (error is StateError) return error.message;
    if (error is FormatException) return error.message;
    return AssistantController._friendlyError(error);
  }
}

enum AssistantStage {
  idle,
  listening,
  recording,
  parsing,
  transcribing,
  processingDocument,
  needsDetails,
  ready,
  confirming,
  saved,
  offlineDraft,
  failed,
}

@immutable
class AssistantState {
  const AssistantState({
    this.stage = AssistantStage.idle,
    this.input,
    this.proposal,
    this.result,
    this.error,
    this.errorKey,
    this.recordingDuration = Duration.zero,
    this.draft,
  });

  final AssistantStage stage;
  final AssistantInput? input;
  final AssistantProposal? proposal;
  final PostedResult? result;
  final String? error;
  final String? errorKey;
  final Duration recordingDuration;
  final LocalDraft? draft;
}

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AssistantState>(
  (ref) => AssistantController(ref),
);

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(this._ref) : super(const AssistantState());

  final Ref _ref;
  Timer? _recordingTimer;
  DateTime? _recordingStartedAt;

  AssistantStage get currentStage => state.stage;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void setListening(bool listening) {
    state = AssistantState(
      stage: listening ? AssistantStage.listening : AssistantStage.idle,
      input: state.input,
    );
  }

  void reset() {
    _recordingTimer?.cancel();
    _recordingStartedAt = null;
    if (state.stage == AssistantStage.recording) {
      unawaited(_ref.read(voiceRecorderProvider).cancel());
    }
    state = const AssistantState();
  }

  void openDraftReview(
    LocalDraft draft, {
    AssistantProposal? proposal,
    String? error,
  }) {
    AssistantInput? input;
    final rawInput = draft.payload['input'];
    if (rawInput is Map) {
      try {
        input = AssistantInput.fromJson(Map<String, dynamic>.from(rawInput));
      } on Object {
        input = null;
      }
    }
    final allowed = proposal == null ||
        _canRecordProposal(
          _ref.read(currentBusinessRoleProvider),
          proposal,
        );
    state = AssistantState(
      stage: proposal == null
          ? AssistantStage.failed
          : _stageForProposal(proposal),
      input: input,
      proposal: proposal,
      error: error,
      errorKey: proposal != null && !allowed ? 'cashierSalesOnly' : null,
      draft: draft,
    );
  }

  AssistantStage _stageForProposal(AssistantProposal proposal) {
    final allowed = _canRecordProposal(
      _ref.read(currentBusinessRoleProvider),
      proposal,
    );
    return proposal.canConfirm && allowed
        ? AssistantStage.ready
        : AssistantStage.needsDetails;
  }

  Future<void> startVoiceRecording() async {
    if (state.stage == AssistantStage.recording) return;
    if (!await _isOnlineAsync()) {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'voiceOffline',
      );
      return;
    }
    try {
      await _ref.read(voiceRecorderProvider).start();
      if (!mounted) return;
      _recordingStartedAt = DateTime.now();
      state = const AssistantState(stage: AssistantStage.recording);
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final startedAt = _recordingStartedAt;
        if (!mounted ||
            startedAt == null ||
            state.stage != AssistantStage.recording) {
          return;
        }
        state = AssistantState(
          stage: AssistantStage.recording,
          recordingDuration: DateTime.now().difference(startedAt),
        );
      });
    } on VoiceRecordingException catch (error) {
      state = AssistantState(
        stage: AssistantStage.failed,
        errorKey: _voiceRecordingErrorKey(error.failure),
      );
    } on Object {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'recordingFailed',
      );
    }
  }

  Future<void> stopVoiceRecordingAndUpload() async {
    if (state.stage != AssistantStage.recording) return;
    _recordingTimer?.cancel();
    _recordingStartedAt = null;
    state = const AssistantState(stage: AssistantStage.transcribing);
    try {
      final recording = await _ref.read(voiceRecorderProvider).stop();
      if (recording == null) {
        state = const AssistantState(
          stage: AssistantStage.failed,
          errorKey: 'emptyRecording',
        );
        return;
      }
      await _uploadRecordedVoice(recording);
    } on VoiceRecordingException catch (error) {
      state = AssistantState(
        stage: AssistantStage.failed,
        errorKey: _voiceRecordingErrorKey(error.failure),
      );
    } on Object {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'recordingFailed',
      );
    }
  }

  Future<void> cancelVoiceRecording() async {
    _recordingTimer?.cancel();
    _recordingStartedAt = null;
    if (state.stage != AssistantStage.recording) return;
    try {
      await _ref.read(voiceRecorderProvider).cancel();
    } on Object {
      // The capture UI is dismissed even if the platform cleanup fails.
    }
    if (mounted) state = const AssistantState();
  }

  Future<void> _uploadRecordedVoice(RecordedVoice recording) async {
    if (!await _isOnlineAsync()) {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'voiceOffline',
      );
      return;
    }
    try {
      final location = await _ref.read(activeLocationProvider.future);
      final language = _ref.read(localeProvider).languageCode;
      final locale = language == 'hi' ? 'hi-IN' : 'en-IN';
      final repository = _ref.read(repositoryProvider);
      final attachmentId = await repository.uploadVoiceRecording(
        businessId: location.businessId,
        bytes: recording.bytes,
      );
      final proposal = await repository.createProposalFromAudio(
        attachmentId: attachmentId,
        businessId: location.businessId,
        locationId: location.id,
        locale: locale,
      );
      final completed = await repository.pollProposal(proposal.id);
      if (!mounted) return;
      final transcript = completed.transcript.trim();
      final allowed = _canRecordProposal(
        _ref.read(currentBusinessRoleProvider),
        completed,
      );
      state = AssistantState(
        stage: _stageForProposal(completed),
        input: AssistantInput(
          type: AssistantInputType.voice,
          content: transcript,
          displayText: transcript.isEmpty ? 'Voice note' : transcript,
        ),
        proposal: completed,
        errorKey: allowed ? null : 'cashierSalesOnly',
      );
    } on VoiceTranscriptionException {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'transcriptionTimeout',
      );
    } on Object {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'voiceUploadFailed',
      );
    }
  }

  Future<void> interpretImage({
    required List<int> bytes,
    required String mimeType,
    required String label,
  }) async {
    if (!await _isOnlineAsync()) {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'imageOffline',
      );
      return;
    }
    if (bytes.isEmpty) {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'documentEmpty',
      );
      return;
    }
    if (bytes.length > maxAttachmentBytes) {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'documentTooLarge',
      );
      return;
    }
    state = const AssistantState(stage: AssistantStage.processingDocument);
    try {
      final location = await _ref.read(activeLocationProvider.future);
      final language = _ref.read(localeProvider).languageCode;
      final locale = language == 'hi' ? 'hi-IN' : 'en-IN';
      final repository = _ref.read(repositoryProvider);
      final attachmentId = await repository.uploadImageAttachment(
        businessId: location.businessId,
        mime: mimeType,
        bytes: bytes,
      );
      final proposal = await repository.createProposalFromImage(
        attachmentId: attachmentId,
        businessId: location.businessId,
        locationId: location.id,
        locale: locale,
      );
      final completed = await repository.pollProposal(proposal.id);
      if (!mounted) return;
      final transcript = completed.transcript.trim();
      final allowed = _canRecordProposal(
        _ref.read(currentBusinessRoleProvider),
        completed,
      );
      state = AssistantState(
        stage: _stageForProposal(completed),
        input: AssistantInput(
          type: AssistantInputType.image,
          content: transcript.isEmpty ? label : transcript,
          displayText: label,
        ),
        proposal: completed,
        errorKey: allowed ? null : 'cashierSalesOnly',
      );
    } on VoiceTranscriptionException {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'documentProcessingTimeout',
      );
    } on Object {
      state = const AssistantState(
        stage: AssistantStage.failed,
        errorKey: 'imageUploadFailed',
      );
    }
  }

  String _voiceRecordingErrorKey(VoiceRecordingFailure failure) =>
      switch (failure) {
        VoiceRecordingFailure.permissionDenied => 'microphonePermission',
        VoiceRecordingFailure.tooLarge => 'recordingTooLarge',
        VoiceRecordingFailure.empty => 'emptyRecording',
        VoiceRecordingFailure.failed => 'recordingFailed',
      };

  Future<void> interpret(AssistantInput input) async {
    final location = await _ref.read(activeLocationProvider.future);
    if (!await _isOnlineAsync()) {
      await _saveAssistantDraft(input, location);
      return;
    }

    state = AssistantState(stage: AssistantStage.parsing, input: input);
    try {
      final locale = _ref.read(localeProvider).languageCode;
      final proposal = await _ref.read(repositoryProvider).interpret(
            input: input,
            locationId: location.id,
            locale: locale,
          );
      final allowed = _canRecordProposal(
        _ref.read(currentBusinessRoleProvider),
        proposal,
      );
      state = AssistantState(
        stage: _stageForProposal(proposal),
        input: input,
        proposal: proposal,
        errorKey: allowed ? null : 'cashierSalesOnly',
      );
    } on Object catch (error) {
      state = AssistantState(
        stage: AssistantStage.failed,
        input: input,
        error: _friendlyError(error),
      );
    }
  }

  Future<void> refreshProposal() async {
    final previous = state;
    final proposal = previous.proposal;
    if (proposal == null) return;
    state = AssistantState(
        stage: AssistantStage.parsing,
        input: previous.input,
        proposal: proposal,
        draft: previous.draft);
    try {
      final refreshed =
          await _ref.read(repositoryProvider).refreshProposal(proposal);
      final draft = previous.draft;
      if (draft != null) {
        await _ref.read(draftStoreProvider).saveDraft(
              LocalDraft(
                id: draft.id,
                kind: draft.kind,
                userId: draft.userId,
                businessId: draft.businessId,
                locationId: draft.locationId,
                label: draft.label,
                payload: {
                  ...draft.payload,
                  'proposal': refreshed.toJson(),
                },
                createdAt: draft.createdAt,
              ),
            );
        _ref.invalidate(localDraftsProvider);
      }
      final allowed = _canRecordProposal(
        _ref.read(currentBusinessRoleProvider),
        refreshed,
      );
      state = AssistantState(
        stage: _stageForProposal(refreshed),
        input: previous.input,
        proposal: refreshed,
        errorKey: allowed ? null : 'cashierSalesOnly',
        draft: draft,
      );
    } on Object catch (error) {
      state = AssistantState(
          stage: AssistantStage.failed,
          input: previous.input,
          proposal: proposal,
          draft: previous.draft,
          error: _friendlyError(error));
    }
  }

  Future<void> retry() async {
    final draft = state.draft;
    if (draft != null) {
      state = AssistantState(
        stage: AssistantStage.parsing,
        input: state.input,
        proposal: state.proposal,
        draft: draft,
      );
      final result = await _ref
          .read(draftSyncProvider.notifier)
          .reviewAssistantDraft(draft);
      if (!mounted) return;
      openDraftReview(
        draft,
        proposal: result.proposal,
        error: result.error,
      );
    } else if (state.proposal != null) {
      await confirm();
    } else if (state.input != null) {
      await interpret(state.input!);
    }
  }

  Future<void> confirm() async {
    final proposal = state.proposal;
    if (proposal == null || !proposal.canConfirm) return;
    final role = _ref.read(currentBusinessRoleProvider);
    if (!_canRecordProposal(role, proposal)) {
      state = AssistantState(
        stage: AssistantStage.failed,
        input: state.input,
        proposal: proposal,
        errorKey: 'cashierSalesOnly',
        draft: state.draft,
      );
      return;
    }
    final draft = state.draft;
    if (!await _isOnlineAsync()) {
      if (draft != null) {
        state = AssistantState(
          stage: AssistantStage.offlineDraft,
          input: state.input,
          proposal: proposal,
          draft: draft,
        );
        return;
      }
      final location = await _ref.read(activeLocationProvider.future);
      await saveScopedDraft(
        _ref,
        kind: DraftKind.assistant,
        location: location,
        label: proposal.title,
        payload: {
          'input': state.input?.toJson(),
          'proposal': proposal.toJson(),
        },
      );
      state = AssistantState(
        stage: AssistantStage.offlineDraft,
        input: state.input,
        proposal: proposal,
      );
      return;
    }

    state = AssistantState(
      stage: AssistantStage.confirming,
      input: state.input,
      proposal: proposal,
      draft: draft,
    );
    try {
      late final PostedResult result;
      if (draft != null) {
        final confirmation = await _ref
            .read(draftSyncProvider.notifier)
            .confirmAssistantDraft(draft, proposal);
        if (!mounted) return;
        if (confirmation.refreshedProposal case final refreshed?) {
          state = AssistantState(
            stage: _stageForProposal(refreshed),
            input: state.input,
            proposal: refreshed,
            error: confirmation.error,
            draft: draft,
          );
          return;
        }
        if (!confirmation.synced || confirmation.postedResult == null) {
          state = AssistantState(
            stage: AssistantStage.failed,
            input: state.input,
            proposal: proposal,
            error: confirmation.error,
            draft: draft,
          );
          return;
        }
        result = confirmation.postedResult!;
      } else {
        result = await _ref.read(repositoryProvider).confirmProposal(proposal);
      }
      invalidateBusinessData(_ref);
      state = AssistantState(
        stage: AssistantStage.saved,
        input: state.input,
        proposal: proposal,
        result: result,
        draft: draft,
      );
    } on Object catch (error) {
      if (error is DioException) {
        final data = error.response?.data;
        final detail = data is Map ? data['error'] : null;
        final body = detail is Map ? detail['detail'] : null;
        if (body is Map && body['code'] == 'stale_proposal_data') {
          await refreshProposal();
          return;
        }
      }
      state = AssistantState(
        stage: AssistantStage.failed,
        input: state.input,
        proposal: proposal,
        draft: draft,
        error: _friendlyError(error),
      );
    }
  }

  Future<void> _saveAssistantDraft(
      AssistantInput input, BusinessLocation location) async {
    await saveScopedDraft(
      _ref,
      kind: DraftKind.assistant,
      location: location,
      label: input.displayText,
      payload: {'input': input.toJson()},
    );
    state = AssistantState(stage: AssistantStage.offlineDraft, input: input);
  }

  Future<bool> _isOnlineAsync() async {
    try {
      return await _ref.read(networkStatusProvider.future);
    } on Object {
      return false;
    }
  }

  static String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final detail = data['error']['detail'];
        if (detail is Map && detail['message'] != null) {
          return detail['message'].toString();
        }
        if (detail is String) return detail;
      }
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'The server could not be reached. Retry to check whether your entry was recorded.';
      }
    }
    return 'The request could not be completed. Retry to check its status.';
  }
}
