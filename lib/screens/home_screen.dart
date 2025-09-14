import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_list_widget.dart';
import '../widgets/summary_card_widget.dart';
import 'settings_screen.dart';
import 'analysis_screen.dart';
import 'watchlist_screen.dart';

/// 主屏幕 - 底部导航栏布局
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const WatchlistScreen(),
    const AnalysisScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await stockProvider.loadConfig();
    await stockProvider.loadAnalysisResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '仪表盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '监控列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

/// 仪表盘屏幕
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('股票监控'),
        actions: [
          Consumer<StockProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () {
                  provider.refreshData();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<StockProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorWidget(context, provider);
          }

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            child: CustomScrollView(
              slivers: [
                // 摘要卡片
                SliverToBoxAdapter(
                  child: SummaryCardWidget(
                    totalStocks: provider.analysisResults.length,
                    signalStocks: provider.analysisResults
                        .where((r) => r.hasYinBeiLiang)
                        .length,
                    avgScore: provider.analysisResults.isNotEmpty
                        ? provider.analysisResults
                            .map((r) => r.score)
                            .reduce((a, b) => a + b) / provider.analysisResults.length
                        : 0,
                  ),
                ),
                
                // 股票列表
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '监控股票',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // 跳转到完整列表
                          },
                          child: const Text('查看全部'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                StockListWidget(
                  analysisResults: provider.analysisResults.take(10).toList(),
                  isLoading: provider.isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, StockProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? '未知错误',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.refreshData();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// 监控列表屏幕占位符
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('监控列表'),
      ),
      body: const Center(
        child: Text('监控列表功能开发中...'),
      ),
    );
  }
}

/// 分析屏幕占位符
class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技术分析'),
      ),
      body: const Center(
        child: Text('技术分析功能开发中...'),
      ),
    );
  }
}

/// 设置屏幕占位符
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: const Center(
        child: Text('设置功能开发中...'),
      ),
    );
  }
}
