import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trivia_showdown/main.dart';

String questionsJson() => jsonEncode({
  'response_code': 0,
  'results': List.generate(
    5,
    (i) => {
      'question': 'Question $i: &quot;A &amp; B&#039;s&quot;?',
      'correct_answer': 'Correct $i',
      'incorrect_answers': ['Wrong ${i}A', 'Wrong ${i}B', 'Wrong ${i}C'],
    },
  ),
});

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> finishRound(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    // Three right and two wrong, with repeated taps to check score locking.
    await tapText(tester, i.isEven ? 'Correct $i' : 'Wrong ${i}A');
    await tapText(tester, 'Correct $i');
    await tapText(tester, i == 4 ? 'View Final Score' : 'Next Question →');
  }
}

void main() {
  testWidgets(
    'shows loading, then decodes five live-response-shaped questions',
    (tester) async {
      final pending = Completer<http.Response>();
      final client = MockClient((request) {
        expect(request.url.queryParameters, {
          'amount': '5',
          'category': '9',
          'difficulty': 'easy',
          'type': 'multiple',
        });
        return pending.future;
      });
      await tester.pumpWidget(TriviaShowdownApp(client: client));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(http.Response(questionsJson(), 200));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Question 0: "A & B\'s"?'), findsOneWidget);
      expect(find.text('Next Question →'), findsNothing);
    },
  );

  testWidgets('wrong choice turns red and correct option green', (
    tester,
  ) async {
    await tester.pumpWidget(
      TriviaShowdownApp(
        client: MockClient((_) async => http.Response(questionsJson(), 200)),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Wrong 0A');
    ElevatedButton button(String text) => tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, text),
    );
    expect(
      button('Wrong 0A').style!.backgroundColor!.resolve({}),
      Colors.red.shade200,
    );
    expect(
      button('Correct 0').style!.backgroundColor!.resolve({}),
      Colors.green.shade200,
    );
    await tapText(tester, 'Correct 0');
    expect(
      button('Wrong 0A').style!.backgroundColor!.resolve({}),
      Colors.red.shade200,
    );
  });

  testWidgets(
    'locks scores, completes, simulates payload, and resets on replay',
    (tester) async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response(questionsJson(), 200);
      });
      await tester.pumpWidget(TriviaShowdownApp(client: client));
      await tester.pumpAndSettle();
      await finishRound(tester);
      expect(find.text('Final Score: 3 / 5'), findsOneWidget);
      await tapText(tester, 'Simulate Score Sync');
      expect(find.text('Simulating sync...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('✓ Sync Simulation Complete'), findsOneWidget);
      final payload = tester
          .widget<SelectableText>(find.byType(SelectableText))
          .data!;
      expect(jsonDecode(payload)['score'], 3);
      expect(jsonDecode(payload)['totalQuestions'], 5);
      expect(requests, 1); // Simulation made no HTTP write.
      await tapText(tester, 'Play Again');
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 5'), findsOneWidget);
      await finishRound(tester);
      expect(find.text('Final Score: 3 / 5'), findsOneWidget);
      expect(find.text('Simulate Score Sync'), findsOneWidget);
      expect(requests, 2);
    },
  );

  testWidgets('HTTP error can recover through retry without a stale message', (
    tester,
  ) async {
    var requests = 0;
    await tester.pumpWidget(
      TriviaShowdownApp(
        client: MockClient((_) async {
          requests++;
          return requests == 1
              ? http.Response('Unavailable', 503)
              : http.Response(questionsJson(), 200);
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Server error: 503'), findsOneWidget);
    await tapText(tester, 'Try Again');
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.textContaining('Server error'), findsNothing);
  });

  for (final scenario in {
    'API error': jsonEncode({'response_code': 5, 'results': []}),
    'empty results': jsonEncode({'response_code': 0, 'results': []}),
    'malformed JSON': 'not json',
  }.entries) {
    testWidgets('${scenario.key} shows an error instead of a round', (
      tester,
    ) async {
      await tester.pumpWidget(
        TriviaShowdownApp(
          client: MockClient((_) async => http.Response(scenario.value, 200)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Question 1 of 5'), findsNothing);
      expect(find.text('Showdown Complete!'), findsNothing);
    });
  }

  testWidgets('timeout reaches a visible retry state', (tester) async {
    final pending = Completer<http.Response>();
    await tester.pumpWidget(
      TriviaShowdownApp(client: MockClient((_) => pending.future)),
    );
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    pending.complete(http.Response(questionsJson(), 200));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('question content scrolls on a small phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 550);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TriviaShowdownApp(
        client: MockClient((_) async => http.Response(questionsJson(), 200)),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Correct 0');
    await tapText(tester, 'Next Question →');
    expect(find.text('Question 2 of 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
