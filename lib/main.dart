import 'package:flutter/material.dart';
import 'package:core_arch/core_arch.dart';
import 'example/core_arch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化 core_arch 内存键值缓存单例
  await SpUtil.init();

  // 2. 打印启动日志
  Logger.i('App 正在启动，core_arch 基础设施已初始化完成', tag: 'Main');

  runApp(const FoundationApp());
}

class FoundationApp extends StatelessWidget {
  const FoundationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Foundation Testbed',
      debugShowCheckedModeBanner: false,

      // 3. 挂载 core_arch 全局悬浮 SnackBar 与弹窗 Context Key
      scaffoldMessengerKey: ToastUtil.messengerKey,
      navigatorKey: ToastUtil.navigatorKey,

      // 4. 挂载 core_arch 桌面端与 Web 端平滑拖拽滚动行为
      scrollBehavior: const AppScrollBehavior(),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FoundationHomeScreen(),
    );
  }
}

class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Foundation 功能底座测试台'),
        centerTitle: true,
      ),
      body: HideKeyboardTap(
        child: Center(
          child: ContentMaxWidth(
            maxWidth: 600,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(
                  Icons.architecture,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  '通用功能底座演练场',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '本工程为 packages/ 各功能底座提供跨端实机测试、演示与验证能力。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // 入口卡片：core_arch 测试样例
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.hub, color: Colors.white),
                    ),
                    title: const Text(
                      'core_arch 架构底座演练样例',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      '测试 MVVM 四态、Dio 网络保护罩、多方位弹窗、响应式自适应、SpUtil 缓存与动效',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const CoreArchExampleScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
