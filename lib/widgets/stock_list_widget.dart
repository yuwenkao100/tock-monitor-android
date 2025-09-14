import 'package:flutter/material.dart';
import '../models/stock_data.dart';
import '../utils/themes.dart';
import 'stock_card_widget.dart';

/// 股票列表组件
class StockListWidget extends StatelessWidget {
  final List<AnalysisResult> analysisResults;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const StockListWidget({
    super.key,
    required this.analysisResults,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && analysisResults.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (analysisResults.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(context),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final result = analysisResults[index];
          return StockCardWidget(
            analysisResult: result,
            onTap: () => _showStockDetail(context, result),
          );
        },
        childCount: analysisResults.length,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无监控数据',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '下拉刷新获取最新数据',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新数据'),
            ),
          ],
        ],
      ),
    );
  }

  void _showStockDetail(BuildContext context, AnalysisResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockDetailSheet(analysisResult: result),
    );
  }
}

/// 股票详情底部弹窗
class StockDetailSheet extends StatelessWidget {
  final AnalysisResult analysisResult;

  const StockDetailSheet({
    super.key,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysisResult.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      analysisResult.code,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(analysisResult.score),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '评分: ${analysisResult.score.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // 详细信息
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    context,
                    '技术信号',
                    [
                      _buildInfoRow('阴背量信号', analysisResult.hasYinBeiLiang ? '是' : '否'),
                      _buildInfoRow('成交量倍数', '${analysisResult.volMultiple.toStringAsFixed(2)}x'),
                      _buildInfoRow('成交量比率', '${analysisResult.volRatio.toStringAsFixed(2)}x'),
                      _buildInfoRow('突破信号', analysisResult.breakoutSignal ? '是' : '否'),
                      _buildInfoRow('收盘接近高点', '${(analysisResult.closeNearHigh * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildInfoSection(
                    context,
                    '移动平均线',
                    analysisResult.movingAverages.entries.map((entry) {
                      return _buildInfoRow(entry.key, entry.value.toStringAsFixed(2));
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildInfoSection(
                    context,
                    '分析时间',
                    [
                      _buildInfoRow('分析日期', _formatDate(analysisResult.analysisDate)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 添加到监控列表
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已添加 ${analysisResult.name} 到监控列表'),
                        ),
                      );
                    },
                    child: const Text('添加监控'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.blue;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
