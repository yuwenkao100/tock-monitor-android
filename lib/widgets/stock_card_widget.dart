import 'package:flutter/material.dart';
import '../models/stock_data.dart';
import '../utils/themes.dart';

/// 股票卡片组件
class StockCardWidget extends StatelessWidget {
  final AnalysisResult analysisResult;
  final VoidCallback? onTap;

  const StockCardWidget({
    super.key,
    required this.analysisResult,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 股票名称和代码
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysisResult.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          analysisResult.code,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 评分标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(analysisResult.score),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      analysisResult.score.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 技术指标行
              Row(
                children: [
                  _buildIndicator(
                    context,
                    '阴背量',
                    analysisResult.hasYinBeiLiang,
                    analysisResult.hasYinBeiLiang ? AppThemes.redColor : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  _buildIndicator(
                    context,
                    '突破',
                    analysisResult.breakoutSignal,
                    analysisResult.breakoutSignal ? AppThemes.redColor : Colors.grey,
                  ),
                  const Spacer(),
                  Text(
                    '量比: ${analysisResult.volRatio.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 移动平均线信息
              if (analysisResult.movingAverages.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMAInfo(context, 'MA20', analysisResult.movingAverages['MA20']),
                    _buildMAInfo(context, 'MA60', analysisResult.movingAverages['MA60']),
                    _buildMAInfo(context, 'MA120', analysisResult.movingAverages['MA120']),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // 底部信息栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '收盘接近高点: ${(analysisResult.closeNearHigh * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatDate(analysisResult.analysisDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建技术指标标签
  Widget _buildIndicator(BuildContext context, String label, bool isActive, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ? color : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// 构建移动平均线信息
  Widget _buildMAInfo(BuildContext context, String label, double? value) {
    if (value == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 根据评分获取颜色
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return AppThemes.primaryColor;
    return Colors.grey;
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

/// 简化版股票卡片（用于列表显示）
class CompactStockCard extends StatelessWidget {
  final AnalysisResult analysisResult;
  final VoidCallback? onTap;

  const CompactStockCard({
    super.key,
    required this.analysisResult,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 股票信息
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysisResult.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      analysisResult.code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 技术指标
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMiniIndicator(analysisResult.hasYinBeiLiang),
                        _buildMiniIndicator(analysisResult.breakoutSignal),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '量比${analysisResult.volRatio.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // 评分
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getScoreColor(analysisResult.score),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    analysisResult.score.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniIndicator(bool isActive) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppThemes.redColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return AppThemes.primaryColor;
    return Colors.grey;
  }
}
