import 'package:agriguard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login validates and opens the leaf scanner', (tester) async {
    await tester.pumpWidget(const AgriGuardBootstrap());

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('usernameField')),
      'student',
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'password',
    );
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Scan any leaf'), findsOneWidget);
    expect(find.text('No crop selection is required.'), findsOneWidget);
  });

  testWidgets('language toggle changes the full login page to Swahili',
      (tester) async {
    await tester.pumpWidget(const AgriGuardBootstrap());

    await tester.tap(find.byKey(const Key('languageToggle')));
    await tester.pumpAndSettle();

    expect(find.text('Karibu tena'), findsOneWidget);
    expect(find.text('Jina la mtumiaji'), findsOneWidget);
    expect(find.text('Nenosiri'), findsOneWidget);
  });
}
