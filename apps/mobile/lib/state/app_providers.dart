import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/data/api_client.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
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

final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(sessionStoreProvider)));

/// Current access token. AuthGate watches this: null means signed out.
/// Bumped explicitly after login/logout since secure storage has no stream.
final sessionTokenProvider = FutureProvider<String?>((ref) async {
  ref.watch(sessionVersionProvider);
  return ref.watch(sessionStoreProvider).readAccessToken();
});

final sessionVersionProvider = StateProvider<int>((ref) => 0);

void bumpSession(WidgetRef ref) => ref.read(sessionVersionProvider.notifier).state++;

final businessesProvider = FutureProvider<List<Business>>(
  (ref) => ref.watch(repositoryProvider).listBusinesses(),
);

/// Sale draft picked from the offline list for review; consumed by the sale form.
final saleDraftResumeProvider = StateProvider<SaleDraft?>((ref) => null);

/// Assistant text picked from the offline list; consumed by the ask screen.
final assistantResumeProvider = StateProvider<String?>((ref) => null);

final dioProvider = Provider<Dio>(
  (ref) => createDio(ref.watch(sessionStoreProvider)),
);

final repositoryProvider = Provider<DukaanRepository>((ref) {
  if (AppConfig.demoMode) return DemoDukaanRepository();
  return ApiDukaanRepository(ref.watch(dioProvider));
});

final networkStatusProvider = StreamProvider<bool>((ref) async* {
  if (AppConfig.demoMode) {
    yield true;
    return;
  }
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
    state = state.languageCode == 'en' ? const Locale('hi') : const Locale('en');
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
  return ref.watch(repositoryProvider).fetchEntries(location.id);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchProducts(location.id);
});

final stockReportProvider = FutureProvider<List<StockRow>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchStockReport(
        businessId: location.businessId,
        locationId: location.id,
      );
});

final partiesProvider = FutureProvider<List<Party>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).fetchParties(location.id);
});

final localDraftsProvider = FutureProvider<List<LocalDraft>>(
  (ref) => ref.watch(draftStoreProvider).listDrafts(),
);

void invalidateBusinessData(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(dashboardProvider);
  invalidate(entriesProvider);
  invalidate(productsProvider);
  invalidate(stockReportProvider);
  invalidate(partiesProvider);
}

enum AssistantStage {
  idle,
  listening,
  parsing,
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
  });

  final AssistantStage stage;
  final AssistantInput? input;
  final AssistantProposal? proposal;
  final PostedResult? result;
  final String? error;
}

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AssistantState>(
  (ref) => AssistantController(ref),
);

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(this._ref) : super(const AssistantState());

  final Ref _ref;

  void setListening(bool listening) {
    state = AssistantState(
      stage: listening ? AssistantStage.listening : AssistantStage.idle,
      input: state.input,
    );
  }

  void reset() => state = const AssistantState();

  Future<void> interpret(AssistantInput input) async {
    final location = await _ref.read(activeLocationProvider.future);
    if (!_isOnline()) {
      await _saveAssistantDraft(input, location.id);
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
      state = AssistantState(
        stage: proposal.canConfirm ? AssistantStage.ready : AssistantStage.needsDetails,
        input: input,
        proposal: proposal,
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
    state = AssistantState(stage: AssistantStage.parsing, input: previous.input, proposal: proposal);
    try {
      final refreshed = await _ref.read(repositoryProvider).refreshProposal(proposal);
      state = AssistantState(
        stage: refreshed.canConfirm ? AssistantStage.ready : AssistantStage.needsDetails,
        input: previous.input, proposal: refreshed,
      );
    } on Object catch (error) {
      state = AssistantState(stage: AssistantStage.failed, input: previous.input,
        proposal: proposal, error: _friendlyError(error));
    }
  }

  Future<void> retry() async {
    if (state.proposal != null) {
      await confirm();
    } else if (state.input != null) {
      await interpret(state.input!);
    }
  }

  Future<void> confirm() async {
    final proposal = state.proposal;
    if (proposal == null || !proposal.canConfirm) return;
    if (!_isOnline()) {
      final location = await _ref.read(activeLocationProvider.future);
      await _ref.read(draftStoreProvider).saveDraft(
            LocalDraft(
              id: const Uuid().v4(),
              kind: DraftKind.assistant,
              locationId: location.id,
              label: proposal.title,
              payload: {
                'input': state.input?.toJson(),
                'proposal': proposal.toJson(),
              },
              createdAt: DateTime.now(),
            ),
          );
      _ref.invalidate(localDraftsProvider);
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
    );
    try {
      final result = await _ref.read(repositoryProvider).confirmProposal(proposal);
      invalidateBusinessData(_ref.invalidate);
      state = AssistantState(
        stage: AssistantStage.saved,
        input: state.input,
        proposal: proposal,
        result: result,
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
        error: _friendlyError(error),
      );
    }
  }

  Future<void> _saveAssistantDraft(AssistantInput input, String locationId) async {
    await _ref.read(draftStoreProvider).saveDraft(
          LocalDraft(
            id: const Uuid().v4(),
            kind: DraftKind.assistant,
            locationId: locationId,
            label: input.displayText,
            payload: {'input': input.toJson()},
            createdAt: DateTime.now(),
          ),
        );
    _ref.invalidate(localDraftsProvider);
    state = AssistantState(stage: AssistantStage.offlineDraft, input: input);
  }

  bool _isOnline() {
    return _ref.read(networkStatusProvider).maybeWhen(
          data: (online) => online,
          orElse: () => AppConfig.demoMode,
        );
  }

  static String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final detail = data['error']['detail'];
        if (detail is Map && detail['message'] != null) return detail['message'].toString();
        if (detail is String) return detail;
      }
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'The server could not be reached. Retry to check whether your entry was recorded.';
      }
    }
    return 'The request could not be completed. Retry to check its status.';
  }
}

