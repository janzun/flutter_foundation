import 'package:flutter/material.dart';
import 'package:core_arch/core_arch.dart';

/// core_arch 模块全功能实机交互测试样例页面
class CoreArchExampleScreen extends StatefulWidget {
  const CoreArchExampleScreen({super.key});

  @override
  State<CoreArchExampleScreen> createState() => _CoreArchExampleScreenState();
}

class _CoreArchExampleScreenState extends State<CoreArchExampleScreen> {
  ViewState _viewState = ViewState.idle;
  String _simulatedData = '';
  int _tapCount = 0;
  String _networkStatus = '未知';
  String _spDisplayValue = '';

  @override
  void initState() {
    super.initState();
    _refreshSpValue();
    _checkNetwork();
  }

  void _refreshSpValue() {
    setState(() {
      _spDisplayValue = SpUtil.getString(
        'example_user_name',
        defaultValue: '未设置 (默认值)',
      );
    });
  }

  Future<void> _checkNetwork() async {
    final connected = await NetworkConnectivity.isConnected;
    if (mounted) {
      setState(() {
        _networkStatus = connected ? '在线 (Connected)' : '离线 (Disconnected)';
      });
    }
  }

  Future<void> _simulateNetworkCall({required bool willFail}) async {
    setState(() {
      _viewState = ViewState.loading;
    });

    Logger.i('开始模拟网络请求: willFail=$willFail', tag: 'CoreArchExample');

    // 模拟网络请求与 guard 保护罩调用
    final Result<String> result = await DioClient.guard<String>(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (willFail) {
        throw const AppException(
          code: 'SIMULATED_FAIL',
          message: '模拟的网络请求失败，请检查网络！',
          statusCode: 500,
        );
      }
      return '用户数据加载成功：ID=${DateTime.now().millisecondsSinceEpoch}';
    });

    if (!mounted) return;

    // 采用 Dart 3 模式匹配
    switch (result) {
      case Ok(value: final data):
        setState(() {
          _viewState = ViewState.success;
          _simulatedData = data;
        });
        ToastUtil.success('数据加载成功！');
      case Err(error: final err):
        setState(() {
          _viewState = ViewState.error;
          _simulatedData = err.message;
        });
        ToastUtil.error('请求出错: [${err.code}] ${err.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('core_arch 真实样例交互测试'),
        actions: [
          IconButton(
            tooltip: '展示全屏 Loading 遮罩',
            icon: const Icon(Icons.hourglass_top),
            onPressed: () async {
              ToastUtil.showLoading(message: '模拟阻塞式处理中 (1.5s)...');
              await Future<void>.delayed(const Duration(milliseconds: 1500));
              ToastUtil.hideLoading();
              ToastUtil.success('处理完成');
            },
          ),
        ],
      ),
      body: HideKeyboardTap(
        child: ContentMaxWidth(
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.all(
              context.responsiveValue(compact: 16.0, expanded: 24.0),
            ),
            children: [
              // 1. 响应式与跨端信息卡片
              _buildResponsiveCard(),
              const SizedBox(height: 16),

              // 2. MVVM 四态切换容器演示
              _buildStateContainerSection(),
              const SizedBox(height: 16),

              // 3. 通用弹窗与确认框测试
              _buildDialogSection(),
              const SizedBox(height: 16),

              // 4. 本地存储 (SpUtil) 读写测试
              _buildStorageSection(),
              const SizedBox(height: 16),

              // 5. 扩展方法 (Extensions) 国际化格式测试
              _buildExtensionsSection(),
              const SizedBox(height: 16),

              // 6. 微动效与防连点测试
              _buildAnimationsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '1. 跨端响应式 (Responsive) 状态',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Text('当前屏幕宽度: ${context.screenWidth.toStringAsFixed(1)} dp'),
            Text('断点形态 (ScreenType): ${context.screenType.name}'),
            Text('判定属性: isMobile=${context.isMobile}, isTablet=${context.isTablet}, isDesktop=${context.isDesktop}'),
            Text('网络状态 (NetworkConnectivity): $_networkStatus'),
          ],
        ),
      ),
    );
  }

  Widget _buildStateContainerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '2. MVVM ViewState & StateLoadWidget 四态演示',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _simulateNetworkCall(willFail: false),
                  child: const Text('模拟成功加载'),
                ),
                FilledButton.tonal(
                  onPressed: () => _simulateNetworkCall(willFail: true),
                  child: const Text('模拟失败异常'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _viewState = ViewState.empty),
                  child: const Text('切为空数据态'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _viewState = ViewState.loading),
                  child: const Text('切为加载中态'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: StateLoadWidget(
                viewState: _viewState,
                errorText: _simulatedData,
                onRetry: () => _simulateNetworkCall(willFail: false),
                contentBuilder: (ctx) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 36),
                      const SizedBox(height: 8),
                      Text(_simulatedData.isEmpty ? '初始空闲状态 (Idle/Success)' : _simulatedData),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.layers_outlined, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '3. 多方位通用弹窗 (DialogUtil)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    DialogUtil.show(
                      position: DialogPosition.bottom,
                      builder: (ctx) => Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('底部弹出面板 (SlideUp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            const Text('适合作为 ActionSheet 或分享菜单。'),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('底部弹窗 (Bottom)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    DialogUtil.show(
                      position: DialogPosition.right,
                      builder: (ctx) => Container(
                        width: 280,
                        height: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('右侧抽屉 (Right Slide)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            const Text('适合桌面端/平板侧边筛选栏。'),
                            const Spacer(),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('右侧滑出 (Right)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await DialogUtil.confirm(
                      title: '确认退出？',
                      content: '退出后需要重新输入账户密码登录。',
                      confirmText: '退出登录',
                      isDestructive: true,
                    );
                    ToastUtil.show('用户选择: $ok');
                  },
                  child: const Text('确认对话框 (Confirm)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  '4. 本地键值缓存 (SpUtil)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Text('当前缓存值 [example_user_name]: $_spDisplayValue'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    await SpUtil.setString('example_user_name', 'Alex (Updated at ${DateTime.now().second}s)');
                    _refreshSpValue();
                    ToastUtil.success('已同步写入内存并异步落盘！');
                  },
                  child: const Text('写入新值'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await SpUtil.remove('example_user_name');
                    _refreshSpValue();
                    ToastUtil.show('已删除键值');
                  },
                  child: const Text('清除该键'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionsSection() {
    final now = DateTime.now();
    const email = 'alex.developer@company.com';
    const phone = '+16508889999';
    final sampleDate = now.subtract(const Duration(minutes: 5));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.extension, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  '5. 出海通用扩展方法 (Extensions)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Text('国际化友好时间: ${sampleDate.timeAgo()} (5分钟前)'),
            Text('标准日期格式: ${now.toFormattedDate()}'),
            Text('国际货币格式 (USD): ${(12999.5).toCurrency(symbol: '\$')}'),
            Text('文件体积计算 (10485760 B): ${(10485760).toByteSizeString()}'),
            Text('邮箱脱敏: $email -> ${email.maskEmail()}'),
            Text('电话脱敏: $phone -> ${phone.maskPhone()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.animation, color: Colors.pink),
                const SizedBox(width: 8),
                Text(
                  '6. 微交互与防抖 (BouncingTap & DebounceTap)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            Text('点击触发计数: $_tapCount 次'),
            const SizedBox(height: 12),
            Row(
              children: [
                // 1. 类似 iOS 负一屏的卡片微按压缩放回弹
                Expanded(
                  child: BouncingTap(
                    onTap: () {
                      setState(() => _tapCount++);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        border: Border.all(color: Colors.pink.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('BouncingTap 弹性微缩放', style: TextStyle(color: Colors.pink)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 2. 防快速重复点击
                Expanded(
                  child: DebounceTap(
                    duration: const Duration(milliseconds: 600),
                    onTap: () {
                      setState(() => _tapCount++);
                      ToastUtil.show('防抖触发 (600ms冷却)');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('DebounceTap 防连点', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 3. 瀑布流入场动效演示
            FadeSlideTransition(
              direction: SlideDirection.bottomToTop,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('FadeSlideTransition: 自带从下往上渐入动效的展示条目'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
