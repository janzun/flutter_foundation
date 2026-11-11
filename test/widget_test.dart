import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foundation/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core_arch/core_arch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FoundationApp smoke test', (WidgetTester tester) async {
    // 模拟 SharedPreferences 假存储
    SharedPreferences.setMockInitialValues({});
    await SpUtil.init();

    await tester.pumpWidget(const FoundationApp());
    await tester.pump();

    expect(find.text('Flutter Foundation 功能底座测试台'), findsOneWidget);
    expect(find.text('core_arch 架构底座演练样例'), findsOneWidget);
  });
}
