import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('shell navigates to assistant and confirms only from review',
      (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeDukaanRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: signedInOverrides(repository: repository),
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

  testWidgets('the primary mic records, uploads, and opens voice review',
      (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeDukaanRepository();
    final recorder = FakeVoiceRecorder();

    await tester.pumpWidget(
      ProviderScope(
        overrides:
            signedInOverrides(repository: repository, recorder: recorder),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('today-assistant-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('assistant-record')));
    await tester.pump();

    expect(find.text('Recording…'), findsOneWidget);
    expect(find.byKey(const Key('assistant-stop-recording')), findsOneWidget);
    expect(recorder.startCalls, 1);
    expect(repository.voiceUploadCalls, 0);

    await tester.tap(find.byKey(const Key('assistant-stop-recording')));
    await tester.pumpAndSettle();

    expect(recorder.stopCalls, 1);
    expect(repository.voiceUploadCalls, 1);
    expect(repository.presignCalls, 0);
    expect(find.byKey(const Key('proposal-confirm')), findsOneWidget);
    expect(repository.confirmCalls, 0);
  });

  testWidgets('a proposal that is not READY cannot be confirmed from review',
      (tester) async {
    tester.view.physicalSize = const Size(430, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _UnreadyProposalRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: signedInOverrides(repository: repository),
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('today-assistant-card')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('assistant-input')), 'Sale to Ramesh');
    await tester.tap(find.byKey(const Key('assistant-submit')));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'This proposal is not ready to record. Edit your request and try again.'),
        findsOneWidget);
    expect(find.byKey(const Key('proposal-confirm')), findsNothing);
    expect(repository.confirmCalls, 0);
  });

  testWidgets('language control switches the shell to Hindi', (tester) async {
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

    await tester.tap(find.byTooltip('हिंदी में देखें'));
    await tester.pumpAndSettle();

    expect(find.text('आज'), findsWidgets);
    expect(find.text('दुकानAI को बताइए क्या हुआ'), findsOneWidget);
  });
}

class _UnreadyProposalRepository extends FakeDukaanRepository {
  @override
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  }) async {
    return AssistantProposal.fromJson({
      'id': 'proposal-unready',
      'version': 1,
      'status': 'DRAFT',
      'command_type': 'SALE',
      'preview': 'Sale to Ramesh',
      'warnings': [],
      'blocking_questions': [],
      'payload': const {},
    });
  }
}
