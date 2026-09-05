import 'package:dukaan_ai_mobile/data/draft_store.dart';
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

  test('offline assistant input becomes a draft and never calls API', () async {
    final repository = FakeDukaanRepository();
    final draftStore = MemoryDraftStore();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        draftStoreProvider.overrideWithValue(draftStore),
        networkStatusProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(networkStatusProvider.future);

    await container.read(assistantControllerProvider.notifier).interpret(input);

    expect(container.read(assistantControllerProvider).stage, AssistantStage.offlineDraft);
    expect(repository.interpretCalls, 0);
    expect(await draftStore.listDrafts(), hasLength(1));
  });

  test('online proposal is read-only until explicit confirmation', () async {
    final repository = FakeDukaanRepository();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        draftStoreProvider.overrideWithValue(MemoryDraftStore()),
        networkStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(networkStatusProvider.future);

    await container.read(assistantControllerProvider.notifier).interpret(input);

    expect(container.read(assistantControllerProvider).stage, AssistantStage.ready);
    expect(repository.interpretCalls, 1);
    expect(repository.confirmCalls, 0);

    await container.read(assistantControllerProvider.notifier).confirm();

    expect(repository.confirmCalls, 1);
    expect(container.read(assistantControllerProvider).stage, AssistantStage.saved);
  });
}
