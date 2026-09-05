import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class DraftStore {
  Future<List<LocalDraft>> listDrafts();
  Future<void> saveDraft(LocalDraft draft);
  Future<void> deleteDraft(String id);
  Future<void> close();
}

class DraftDatabase extends GeneratedDatabase {
  DraftDatabase(super.executor);

  factory DraftDatabase.memory() => DraftDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (_) async {
          await customStatement('''
            CREATE TABLE local_drafts (
              id TEXT PRIMARY KEY NOT NULL,
              kind TEXT NOT NULL,
              location_id TEXT NOT NULL,
              label TEXT NOT NULL,
              payload TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        },
      );
}

class DriftDraftStore implements DraftStore {
  DriftDraftStore(this._database);

  final DraftDatabase _database;

  static Future<DriftDraftStore> open() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/dukaan_offline_drafts.sqlite');
    return DriftDraftStore(DraftDatabase(NativeDatabase.createInBackground(file)));
  }

  @override
  Future<List<LocalDraft>> listDrafts() async {
    final rows = await _database.customSelect(
      'SELECT * FROM local_drafts ORDER BY created_at DESC',
    ).get();
    return rows.map((row) {
      final data = row.data;
      return LocalDraft(
        id: data['id']! as String,
        kind: DraftKind.values.byName(data['kind']! as String),
        locationId: data['location_id']! as String,
        label: data['label']! as String,
        payload: Map<String, dynamic>.from(
          jsonDecode(data['payload']! as String) as Map,
        ),
        createdAt: DateTime.parse(data['created_at']! as String),
      );
    }).toList(growable: false);
  }

  @override
  Future<void> saveDraft(LocalDraft draft) {
    return _database.customStatement(
      '''
        INSERT INTO local_drafts(id, kind, location_id, label, payload, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          kind = excluded.kind,
          location_id = excluded.location_id,
          label = excluded.label,
          payload = excluded.payload,
          created_at = excluded.created_at
      ''',
      [
        draft.id,
        draft.kind.name,
        draft.locationId,
        draft.label,
        draft.encodedPayload,
        draft.createdAt.toIso8601String(),
      ],
    );
  }

  @override
  Future<void> deleteDraft(String id) =>
      _database.customStatement('DELETE FROM local_drafts WHERE id = ?', [id]);

  @override
  Future<void> close() => _database.close();
}

class MemoryDraftStore implements DraftStore {
  final Map<String, LocalDraft> _drafts = {};

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteDraft(String id) async => _drafts.remove(id);

  @override
  Future<List<LocalDraft>> listDrafts() async {
    final drafts = _drafts.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return drafts;
  }

  @override
  Future<void> saveDraft(LocalDraft draft) async => _drafts[draft.id] = draft;
}

