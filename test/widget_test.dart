import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dam_g2/main.dart';

void main() {
  testWidgets('homepage opens the second page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Open Second Page'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('You have pushed the button this many times:'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Second Page'), findsOneWidget);
    expect(find.text('Welcome to the second page.'), findsOneWidget);
  });
}
