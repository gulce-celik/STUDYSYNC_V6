import 'package:flutter_test/flutter_test.dart';

import 'package:studysync_mobile/app.dart';
import 'package:studysync_mobile/core/auth/auth_controller.dart';
import 'package:studysync_mobile/core/auth/auth_scope.dart';

void main() {
  testWidgets('StudySync app boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      AuthScope(
        notifier: AuthController(),
        child: const StudySyncApp(),
      ),
    );
    expect(find.textContaining('StudySync'), findsWidgets);
  });
}
