import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'demo_view_model.dart';

/// 这是一个演示 MVI/MVVM 架构的标准页面，结合 Provider 及其 Consumer 呈现。
/// 这里的职责是：渲染 UI (Render) + 监听发送动作 (Dispatch Intents)
class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  /// 1. 定义页面路由名称
  static const String routeName = '/demo_screen';

  /// 2. 定义启动路由的静态方法，规范跳转入口
  static void start(BuildContext context) {
    context.push(routeName);
  }

  /// 3. 定义返回 GoRoute 的静态方法，便于在 Router 配置中心统一注册。
  /// 此处包含了 ViewModel 的注入逻辑，确保其生命周期与页面绑定。
  static GoRoute route() {
    return GoRoute(
      path: routeName,
      builder: (context, state) => ChangeNotifierProvider<DemoViewModel>(
        create: (_) => DemoViewModel(),
        child: const DemoScreen(),
      ),
    );
  }

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // 注意：此处不再需要收纳 StreamSubscription，已交由 BaseViewModel 内部托管自动释放


  @override
  void initState() {
    super.initState();
    
    // 【架构要求/最佳实践】：在 initState 中务必订阅 ViewModel 下发的 UI Event 流。
    // 使用 addPostFrameCallback 是确保当前 Widget 树已经绑定 Context 并完成了首次注入。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DemoViewModel>();
      
      // 开始监听事件大巴，内部会自动管理生命周期
      viewModel.listenEvent(_onUiEvent);
    });
  }

  /// -----------------------------------------------------------------------
  /// 集中处理 ViewModel 端派发下来的所有一次性事件 (Side Effect/Event)
  /// 如：Toast、对话框 Dialog，甚至所有的页面路由流转 Navigation 跳转等
  /// -----------------------------------------------------------------------
  void _onUiEvent(DemoUiEvent event) {
    // 既然在 ViewModel 里使用了 sealed class，这里可以使用 Dart 3 的 switch 匹配。
    // 这种写法下，如果未来在 DemoUiEvent 里新增了子类，编译器会强制要求你在这里处理。
    switch (event) {
      case ShowToastEvent(message: var msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      case NavigateToLoginEvent():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mock: 执行页面流转 - 跳转至登录页"),
            backgroundColor: Colors.redAccent,
          ),
        );
    }
  }

  @override
  void dispose() {
    // 无需手动触发 subscription.cancel()，ViewModel 的 dispose 会负责清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 【架构要求】：全局请使用 Consumer 来将 UI 与 ViewModel 的状态进行绑定。
    // Consumer 只会在 ViewModel 内主动调用了 `notifyListeners` (本架构里被封装在 `updateUiState` 之中) 时才会自动刷新其包裹的所有子节点。
    return Consumer<DemoViewModel>(
      builder: (context, viewModel, child) {
        
        // 拿到当前的真实聚合 UI 状态树
        final state = viewModel.uiState;

        return Scaffold(
          appBar: AppBar(
            title: const Text('MVI / MVVM Demo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                // 按钮被点击，直接转发给 ViewModel 触发，View层里绝不能参杂一点业务与判断代码
                onPressed: viewModel.logout, 
              )
            ],
          ),
          body: Center(
            // 这里可以直接通过状态去决定渲染分支
            child: state.isLoading
                ? const CircularProgressIndicator() // True 加载圈
                : Column(                           // False 业务内容渲染
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('欢迎回来,'),
                      Text(
                        state.username, // 数据从 State 获取
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      const Text('当前点击次数:'),
                      Text(
                        '${state.counter}', // 数据从 State 获取
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            // 同样，直接把点击行为推给 ViewModel 进行全权托管
            onPressed: viewModel.incrementCounter,
            tooltip: '点击累加+',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
