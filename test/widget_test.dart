import 'package:flutter_test/flutter_test.dart';
import 'package:solid_state_quiz/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SolidStateQuizApp());
    expect(find.byType(SolidStateQuizApp), findsOneWidget);
  });
}
