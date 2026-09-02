import 'package:flutter_test/flutter_test.dart';
import 'package:deputatapp/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const DeputatApp());
    expect(find.byType(DeputatApp), findsOneWidget);
  });
}
