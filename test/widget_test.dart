import 'package:flutter_test/flutter_test.dart';
import 'package:lexiadapt/app.dart';

void main() {
  testWidgets('App renders role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LexiAdaptApp());
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text("I'm a Student"), findsOneWidget);
    expect(find.text("I'm a Teacher"), findsOneWidget);
  });
}
