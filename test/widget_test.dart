// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aduin_jember/main.dart';

void main() {
  testWidgets('shows login screen by default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AduinJemberApp());
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Masuk ke Aduin Jember'), findsOneWidget);
  });
}
