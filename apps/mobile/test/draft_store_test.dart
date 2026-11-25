import 'package:drift/native.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

LocalDraft draft({
  String id = 'draft-1',
  String userId = 'user-1',
  String businessId = 'business-1',
}) =>
    LocalDraft(
      id: id,
      kind: DraftKind.assistant,
      userId: userId,
      businessId: businessId,
      locationId: 'location-1',
      label: 'Ramesh sale',
      payload: const {'content': 'three shirts'},
      createdAt: DateTime.utc(2026, 9, 4, 8),
    );

void main() {
  test('Drift draft store persists, scopes, and deletes device-only drafts',
      () async {
    final store = DriftDraftStore(DraftDatabase.memory());
    addTearDown(store.close);
    final own = draft();
    final otherUser = draft(id: 'draft-2', userId: 'user-2');
    final otherBusiness = draft(id: 'draft-3', businessId: 'business-2');

    await store.saveDraft(own);
    await store.saveDraft(otherUser);
    await store.saveDraft(otherBusiness);
    final saved = await store.listDrafts(
      userId: 'user-1',
      businessId: 'business-1',
    );

    expect(saved, hasLength(1));
    expect(saved.single.id, own.id);
    expect(saved.single.payload, own.payload);

    await store.deleteDraft(
      own.id,
      userId: 'user-2',
      businessId: 'business-1',
    );
    expect(
      await store.listDrafts(userId: 'user-1', businessId: 'business-1'),
      hasLength(1),
    );

    await store.deleteDraft(
      own.id,
      userId: 'user-1',
      businessId: 'business-1',
    );
    expect(
      await store.listDrafts(userId: 'user-1', businessId: 'business-1'),
      isEmpty,
    );
  });

  test('v1 drafts migrate to v2 but remain quarantined without an owner',
      () async {
    final executor = NativeDatabase.memory(setup: (database) {
      database.execute('''
        CREATE TABLE local_drafts (
          id TEXT PRIMARY KEY NOT NULL,
          kind TEXT NOT NULL,
          location_id TEXT NOT NULL,
          label TEXT NOT NULL,
          payload TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      database.execute(
        'INSERT INTO local_drafts VALUES (?, ?, ?, ?, ?, ?)',
        [
          'legacy-draft',
          'sale',
          'location-1',
          'Legacy unscoped sale',
          '{"business_id":"business-1"}',
          '2026-01-01T00:00:00.000Z',
        ],
      );
      database.execute('PRAGMA user_version = 1');
    });
    final database = DraftDatabase(executor);
    final store = DriftDraftStore(database);
    addTearDown(store.close);

    final version =
        await database.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 2);
    expect(
      await store.listDrafts(userId: 'user-1', businessId: 'business-1'),
      isEmpty,
    );
    expect(
      await store.listDrafts(userId: 'user-2', businessId: 'business-1'),
      isEmpty,
    );

    await store.saveDraft(draft());
    expect(
      await store.listDrafts(userId: 'user-1', businessId: 'business-1'),
      hasLength(1),
    );
    final rows =
        await database.customSelect('SELECT * FROM local_drafts').get();
    expect(rows, hasLength(2));
    expect(
        rows
            .firstWhere((row) => row.data['id'] == 'legacy-draft')
            .data['user_id'],
        isNull);
  });

  test('MemoryDraftStore applies the same cross-user isolation', () async {
    final store = MemoryDraftStore();
    await store.saveDraft(draft());
    await store.saveDraft(draft(id: 'draft-2', userId: 'user-2'));

    expect(
      await store.listDrafts(userId: 'user-1', businessId: 'business-1'),
      hasLength(1),
    );
    expect(
      await store.listDrafts(userId: 'user-2', businessId: 'business-1'),
      hasLength(1),
    );
    await store.deleteDraft(
      'draft-2',
      userId: 'user-1',
      businessId: 'business-1',
    );
    expect(
      await store.listDrafts(userId: 'user-2', businessId: 'business-1'),
      hasLength(1),
    );
  });
}
