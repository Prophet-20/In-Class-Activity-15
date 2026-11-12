import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trivia_showdown/main.dart';

// These captures show controlled request states, not a live server outage.
Future<void> capture(WidgetTester tester, String filename) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('evidence')),
  );
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('evidence/$filename');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}

void main() {
  setUpAll(() async {
    final bytes = await File('test/fonts/Roboto-Regular.ttf').readAsBytes();
    for (final family in ['Roboto', 'Ahem']) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  });
  testWidgets('capture loading and controlled HTTP failure', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pending = Completer<http.Response>();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('evidence'),
        child: TriviaShowdownApp(client: MockClient((_) => pending.future)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.runAsync(() => capture(tester, '10-controlled-loading.png'));

    pending.complete(http.Response('Service unavailable', 503));
    await tester.pumpAndSettle();
    expect(find.text('Server error: 503. Please try again.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    await tester.runAsync(
      () => capture(tester, '11-controlled-http-error.png'),
    );
  });
}
