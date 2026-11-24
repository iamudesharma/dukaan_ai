import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('a new owner creates a shop with its first location',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeDukaanRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          sessionStoreProvider.overrideWithValue(
            MemorySessionStore(access: 'access', refresh: 'refresh'),
          ),
        ],
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Nothing to submit until the shop has a name.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Gupta Traders');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), 'Karol Bagh');
    await tester.enterText(find.byType(TextField).at(3), '07aaaaa0000a1z5');
    await tester.pump();

    await tester.ensureVisible(find.text('Create my shop'));
    await tester.tap(find.text('Create my shop'));
    await tester.pumpAndSettle();

    expect(repository.lastBusinessPayload, {
      'name': 'Gupta Traders',
      'gstin': '07AAAAA0000A1Z5',
      'location_name': 'Karol Bagh',
    });
  });
}
