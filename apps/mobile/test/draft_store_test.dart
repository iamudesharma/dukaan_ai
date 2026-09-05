import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drift draft store persists and deletes device-only drafts', () async {
    final store = DriftDraftStore(DraftDatabase.memory());
    addTearDown(store.close);
    final draft = LocalDraft(
      id: 'draft-1',
      kind: DraftKind.assistant,
      locationId: 'location-1',
      label: 'Ramesh sale',
      payload: const {'content': 'three shirts'},
      createdAt: DateTime.utc(2026, 9, 4, 8),
    );

    await store.saveDraft(draft);
    final saved = await store.listDrafts();

    expect(saved, hasLength(1));
    expect(saved.single.id, draft.id);
    expect(saved.single.payload, draft.payload);

    await store.deleteDraft(draft.id);
    expect(await store.listDrafts(), isEmpty);
  });
}

