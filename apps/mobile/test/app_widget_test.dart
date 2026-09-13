import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<List<Override>> signedInOverrides({DukaanRepository? repository}) async {
  final session = MemorySessionStore();
  await session.writeAccessToken('test-token');
  return [
    repositoryProvider.overrideWithValue(repository ?? FakeDukaanRepository()),
    sessionStoreProvider.overrideWithValue(session),
    draftStoreProvider.overrideWithValue(MemoryDraftStore()),
    networkStatusProvider.overrideWith((ref) => Stream.value(true)),
  ];
}

void main() {
  testWidgets('shell navigates to assistant and confirms only from review', (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeDukaanRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: await signedInOverrides(repository: repository),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('today-assistant-card')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('assistant-input')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('assistant-input')),
      'Ramesh bought 3 shirts for 2400, 900 pending',
    );
    await tester.tap(find.byKey(const Key('assistant-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposal-confirm')), findsOneWidget);
    expect(repository.confirmCalls, 0);

    await tester.tap(find.byKey(const Key('proposal-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Entry recorded'), findsOneWidget);
    expect(repository.confirmCalls, 1);
  });

  testWidgets('language control switches the shell to Hindi', (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: await signedInOverrides(),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('हिंदी में देखें'));
    await tester.pumpAndSettle();

    expect(find.text('आज'), findsWidgets);
    expect(find.text('दुकानAI को बताइए क्या हुआ'), findsOneWidget);
  });
}
