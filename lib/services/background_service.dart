import 'dart:async';
import 'dart:isolate';
import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';
import '../models/stock_data.dart';
import 'api_service.dart';
import 'database_service.dart';
import 'analysis_service.dart';
import 'notification_service.dart';

/// 后台监控服务
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  final Logger _logger = Logger();
  static const String _taskName = 'stock_monitor_task';
  static const String _periodicTaskName = 'periodic_stock_monitor';

  /// 初始化后台服务
  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // 生产环境设为false
    );
    _logger.i('BackgroundService initialized');
  }

  /// 启动定期监控任务
  Future<void> startPeriodicMonitoring({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    await Workmanager().registerPeriodicTask(
      _periodicTaskName,
      _taskName,
      frequency: frequency,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      inputData: {
        'task_type': 'periodic_monitor',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    _logger.i('Periodic monitoring started with frequency: ${frequency.inMinutes} minutes');
  }

  /// 停止定期监控任务
  Future<void> stopPeriodicMonitoring() async {
    await Workmanager().cancelByUniqueName(_periodicTaskName);
    _logger.i('Periodic monitoring stopped');
  }

  /// 启动一次性监控任务
  Future<void> startOneTimeMonitoring({
    Duration delay = Duration.zero,
  }) async {
    await Workmanager().registerOneOffTask(
      'one_time_${DateTime.now().millisecondsSinceEpoch}',
      _taskName,
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'task_type': 'one_time_monitor',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    _logger.i('One-time monitoring task scheduled');
  }

  /// 取消所有后台任务
  Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    _logger.i('All background tasks cancelled');
  }

  /// 检查后台任务状态
  Future<bool> isMonitoringActive() async {
    // WorkManager没有直接的API来检查任务状态
    // 这里可以通过其他方式实现，比如存储状态到SharedPreferences
    return true; // 简化实现
  }
}

/// 后台任务回调分发器
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final logger = Logger();
    logger.i('Background task started: $task');

    try {
      switch (task) {
        case 'stock_monitor_task':
          await _executeMonitoringTask(inputData);
          break;
        default:
          logger.w('Unknown task: $task');
          return false;
      }
      
      logger.i('Background task completed successfully: $task');
      return true;
    } catch (e) {
      logger.e('Background task failed: $task, error: $e');
      return false;
    }
  });
}

/// 执行监控任务
Future<void> _executeMonitoringTask(Map<String, dynamic>? inputData) async {
  final logger = Logger();
  final apiService = EastmoneyApiService();
  final databaseService = DatabaseService();
  final analysisService = AnalysisService();
  final notificationService = NotificationService();

  try {
    // 初始化服务
    await apiService.init();
    await notificationService.init();

    // 获取监控配置
    final config = await databaseService.getMonitorConfig();
    
    // 获取监控股票列表（这里简化为获取涨停股票）
    final limitUpData = await apiService.getLimitUpData();
    final stockCodes = limitUpData
        .take(20) // 限制数量避免过多请求
        .map((data) => data['f12'] as String)
        .toList();

    logger.i('Monitoring ${stockCodes.length} stocks');

    final newSignals = <AnalysisResult>[];

    // 分析每只股票
    for (final code in stockCodes) {
      try {
        // 获取K线数据
        final klineData = await apiService.getKlineData(code, count: 200);
        
        if (klineData.length < 120) continue; // 数据不足跳过

        // 执行技术分析
        final result = analysisService.analyzeYinBeiLiang(klineData, config);
        
        // 保存分析结果
        await databaseService.saveAnalysisResult(result);

        // 检查是否有新信号
        if (_isSignificantSignal(result)) {
          newSignals.add(result);
        }

        // 避免请求过于频繁
        await Future.delayed(const Duration(milliseconds: 500));
        
      } catch (e) {
        logger.w('Failed to analyze stock $code: $e');
        continue;
      }
    }

    // 发送通知
    if (newSignals.isNotEmpty) {
      await _sendSignalNotifications(newSignals, notificationService);
    }

    // 清理过期数据
    await databaseService.cleanupOldData();

    logger.i('Monitoring task completed. Found ${newSignals.length} new signals');

  } catch (e) {
    logger.e('Monitoring task failed: $e');
    
    // 发送错误通知
    await notificationService.sendSystemNotification(
      '监控任务失败',
      '后台监控遇到错误，请检查网络连接',
    );
  }
}

/// 判断是否为重要信号
bool _isSignificantSignal(AnalysisResult result) {
  // 评分高于60分且有阴背量信号
  if (result.score >= 60 && result.hasYinBeiLiang) {
    return true;
  }
  
  // 评分高于80分
  if (result.score >= 80) {
    return true;
  }
  
  // 有突破信号且量比大于2
  if (result.breakoutSignal && result.volRatio >= 2.0) {
    return true;
  }
  
  return false;
}

/// 发送信号通知
Future<void> _sendSignalNotifications(
  List<AnalysisResult> signals,
  NotificationService notificationService,
) async {
  final logger = Logger();
  
  // 按评分排序，优先通知高分股票
  signals.sort((a, b) => b.score.compareTo(a.score));
  
  // 限制通知数量，避免过多通知打扰用户
  final topSignals = signals.take(3).toList();
  
  for (final signal in topSignals) {
    try {
      await notificationService.sendStockSignalNotification(signal);
      // 通知间隔，避免同时发送多个通知
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      logger.e('Failed to send notification for ${signal.code}: $e');
    }
  }
  
  // 如果有更多信号，发送汇总通知
  if (signals.length > 3) {
    await notificationService.sendSystemNotification(
      '发现多个股票信号',
      '共发现 ${signals.length} 个股票信号，请打开应用查看详情',
    );
  }
}

/// 后台服务管理器
class BackgroundServiceManager {
  static final BackgroundServiceManager _instance = BackgroundServiceManager._internal();
  factory BackgroundServiceManager() => _instance;
  BackgroundServiceManager._internal();

  final BackgroundService _backgroundService = BackgroundService();
  bool _isEnabled = false;

  /// 启用后台监控
  Future<void> enableBackgroundMonitoring({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    if (_isEnabled) return;

    await _backgroundService.init();
    await _backgroundService.startPeriodicMonitoring(frequency: frequency);
    _isEnabled = true;
  }

  /// 禁用后台监控
  Future<void> disableBackgroundMonitoring() async {
    if (!_isEnabled) return;

    await _backgroundService.stopPeriodicMonitoring();
    _isEnabled = false;
  }

  /// 立即执行一次监控
  Future<void> executeImmediateMonitoring() async {
    await _backgroundService.startOneTimeMonitoring();
  }

  /// 检查是否启用
  bool get isEnabled => _isEnabled;

  /// 更新监控频率
  Future<void> updateMonitoringFrequency(Duration frequency) async {
    if (_isEnabled) {
      await _backgroundService.stopPeriodicMonitoring();
      await _backgroundService.startPeriodicMonitoring(frequency: frequency);
    }
  }
}
