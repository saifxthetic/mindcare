import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/main.dart';

void main() {
  testWidgets('MindCare app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MindCareApp());

    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}