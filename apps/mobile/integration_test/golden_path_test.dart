import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/fakes.dart';

/// Golden path on a real device/emulator: signed-in shell, assistant
/// draft → review → confirm records an entry.
///
/// Run: `flutter test integration_test` (connected device or emulator).
/// Uses the fake repository, so no backend is required; it exercises the
/// real navigation, state, and review gating end to end.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('golden path records an entry from the assistant', (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeDukaanRepository();
    final session = MemorySessionStore();
    await session.writeAccessToken('integration-token');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          sessionStoreProvider.overrideWithValue(session),
          draftStoreProvider.overrideWithValue(MemoryDraftStore()),
          networkStatusProvider.overrideWith((ref) => Stream.value(true)),
        ],
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
}
