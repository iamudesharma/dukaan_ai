import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class DraftStore {
  Future<List<LocalDraft>> listDrafts({
    required String userId,
    required String businessId,
  });
  Future<void> saveDraft(LocalDraft draft);
  Future<void> deleteDraft(
    String id, {
    required String userId,
    required String businessId,
  });
  Future<void> close();
}

class DraftDatabase extends GeneratedDatabase {
  DraftDatabase(super.executor);

  factory DraftDatabase.memory() => DraftDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (_) async {
          await customStatement('''
            CREATE TABLE local_drafts (
              id TEXT PRIMARY KEY NOT NULL,
              kind TEXT NOT NULL,
              user_id TEXT NOT NULL,
              business_id TEXT NOT NULL,
              location_id TEXT NOT NULL,
              label TEXT NOT NULL,
              payload TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await _createScopeIndex();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            // v1 rows have no trustworthy owner. Nullable columns quarantine
            // them: no scoped query can ever return or send those rows.
            await customStatement(
                'ALTER TABLE local_drafts ADD COLUMN user_id TEXT');
            await customStatement(
                'ALTER TABLE local_drafts ADD COLUMN business_id TEXT');
            await _createScopeIndex();
          }
        },
      );

  Future<void> _createScopeIndex() => customStatement('''
        CREATE INDEX IF NOT EXISTS local_drafts_scope
        ON local_drafts(user_id, business_id, created_at DESC)
      ''');
}

class DriftDraftStore implements DraftStore {
  DriftDraftStore(this._database);

  final DraftDatabase _database;

  static Future<DriftDraftStore> open() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/dukaan_offline_drafts.sqlite');
    return DriftDraftStore(
        DraftDatabase(NativeDatabase.createInBackground(file)));
  }

  @override
  Future<List<LocalDraft>> listDrafts({
    required String userId,
    required String businessId,
  }) async {
    _requireScope(userId, businessId);
    final rows = await _database.customSelect(
      'SELECT * FROM local_drafts '
      'WHERE user_id = ? AND business_id = ? ORDER BY created_at DESC',
      variables: [Variable(userId), Variable(businessId)],
    ).get();
    return rows.map((row) {
      final data = row.data;
      return LocalDraft(
        id: data['id']! as String,
        kind: DraftKind.values.byName(data['kind']! as String),
        userId: data['user_id']! as String,
        businessId: data['business_id']! as String,
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
    _requireScope(draft.userId, draft.businessId);
    return _database.customStatement(
      '''
        INSERT INTO local_drafts(
          id, kind, user_id, business_id, location_id, label, payload, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          kind = excluded.kind,
          user_id = excluded.user_id,
          business_id = excluded.business_id,
          location_id = excluded.location_id,
          label = excluded.label,
          payload = excluded.payload,
          created_at = excluded.created_at
        WHERE local_drafts.user_id = excluded.user_id
          AND local_drafts.business_id = excluded.business_id
      ''',
      [
        draft.id,
        draft.kind.name,
        draft.userId,
        draft.businessId,
        draft.locationId,
        draft.label,
        draft.encodedPayload,
        draft.createdAt.toIso8601String(),
      ],
    );
  }

  @override
  Future<void> deleteDraft(
    String id, {
    required String userId,
    required String businessId,
  }) {
    _requireScope(userId, businessId);
    return _database.customStatement(
      'DELETE FROM local_drafts WHERE id = ? AND user_id = ? AND business_id = ?',
      [id, userId, businessId],
    );
  }

  static void _requireScope(String userId, String businessId) {
    if (userId.isEmpty || businessId.isEmpty) {
      throw ArgumentError('Draft user and business scope must not be empty.');
    }
  }

  @override
  Future<void> close() => _database.close();
}

class MemoryDraftStore implements DraftStore {
  final Map<String, LocalDraft> _drafts = {};

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteDraft(
    String id, {
    required String userId,
    required String businessId,
  }) async {
    _requireScope(userId, businessId);
    final draft = _drafts[id];
    if (draft?.belongsTo(userId: userId, businessId: businessId) ?? false) {
      _drafts.remove(id);
    }
  }

  @override
  Future<List<LocalDraft>> listDrafts({
    required String userId,
    required String businessId,
  }) async {
    _requireScope(userId, businessId);
    final drafts = _drafts.values
        .where((draft) => draft.belongsTo(
              userId: userId,
              businessId: businessId,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return drafts;
  }

  @override
  Future<void> saveDraft(LocalDraft draft) async {
    _requireScope(draft.userId, draft.businessId);
    final existing = _drafts[draft.id];
    if (existing != null &&
        !existing.belongsTo(
          userId: draft.userId,
          businessId: draft.businessId,
        )) {
      throw StateError(
          'A draft id cannot be moved to another user or business.');
    }
    _drafts[draft.id] = draft;
  }

  static void _requireScope(String userId, String businessId) {
    if (userId.isEmpty || businessId.isEmpty) {
      throw ArgumentError('Draft user and business scope must not be empty.');
    }
  }
}
