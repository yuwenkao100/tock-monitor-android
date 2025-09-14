import 'package:flutter/material.dart';
import '../utils/themes.dart';

/// 摘要卡片组件
class SummaryCardWidget extends StatelessWidget {
  final int totalStocks;
  final int signalStocks;
  final double avgScore;

  const SummaryCardWidget({
    super.key,
    required this.totalStocks,
    required this.signalStocks,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 主要统计卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        '监控股票',
                        totalStocks.toString(),
                        Icons.trending_up,
                        AppThemes.primaryColor,
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        context,
                        '信号股票',
                        signalStocks.toString(),
                        Icons.notifications_active,
                        AppThemes.redColor,
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        context,
                        '平均评分',
                        avgScore.toStringAsFixed(1),
                        Icons.star,
                        Colors.orange,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 进度条显示信号股票比例
                  if (totalStocks > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '信号比例',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${((signalStocks / totalStocks) * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: signalStocks / totalStocks,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(signalStocks / totalStocks),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 快速操作按钮
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: 跳转到信号股票列表
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: AppThemes.redColor,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '查看信号',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: 跳转到设置页面
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.tune,
                            color: AppThemes.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '调整参数',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: 跳转到分析页面
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '深度分析',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  /// 根据比例获取进度条颜色
  Color _getProgressColor(double ratio) {
    if (ratio >= 0.3) return AppThemes.redColor;
    if (ratio >= 0.2) return Colors.orange;
    if (ratio >= 0.1) return AppThemes.primaryColor;
    return Colors.grey;
  }
}

/// 市场概览卡片
class MarketOverviewCard extends StatelessWidget {
  final String marketStatus;
  final DateTime lastUpdateTime;
  final int activeStocks;
  final int limitUpStocks;

  const MarketOverviewCard({
    super.key,
    required this.marketStatus,
    required this.lastUpdateTime,
    required this.activeStocks,
    required this.limitUpStocks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '市场概览',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMarketStatusColor(marketStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    marketStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarketStat(context, '活跃股票', activeStocks.toString()),
                _buildMarketStat(context, '涨停股票', limitUpStocks.toString()),
                _buildMarketStat(context, '更新时间', _formatTime(lastUpdateTime)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getMarketStatusColor(String status) {
    switch (status) {
      case '开盘':
        return Colors.green;
      case '收盘':
        return Colors.grey;
      case '休市':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
