import 'package:dukaan_ai_mobile/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('a first launch lands on the sign-in screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: signedOutOverrides(),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create a new account'), findsOneWidget);
  });

  testWidgets('a stored session opens the shop shell', (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: signedInOverrides(),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Shop'), findsWidgets);
    // The demo banner is gone for good.
    expect(find.text('Demo data'), findsNothing);
  });
}
