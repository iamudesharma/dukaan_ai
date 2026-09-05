import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final draftStore = await DriftDraftStore.open();
  runApp(
    ProviderScope(
      overrides: [draftStoreProvider.overrideWithValue(draftStore)],
      child: const DukaanApp(),
    ),
  );
}

