import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../models/stock_data.dart';

/// 通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _isInitialized = false;

  /// 初始化通知服务
  Future<void> init() async {
    if (_isInitialized) return;

    // Android初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 创建通知渠道
    await _createNotificationChannels();

    _isInitialized = true;
    _logger.i('NotificationService initialized');
  }

  /// 创建通知渠道
  Future<void> _createNotificationChannels() async {
    // 股票信号通知渠道
    const AndroidNotificationChannel signalChannel = AndroidNotificationChannel(
      'stock_signals',
      '股票信号',
      description: '股票技术分析信号通知',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // 价格提醒通知渠道
    const AndroidNotificationChannel priceAlertChannel = AndroidNotificationChannel(
      'price_alerts',
      '价格提醒',
      description: '股票价格变动提醒',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    // 系统通知渠道
    const AndroidNotificationChannel systemChannel = AndroidNotificationChannel(
      'system_notifications',
      '系统通知',
      description: '应用系统通知',
      importance: Importance.low,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(signalChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(priceAlertChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(systemChannel);
  }

  /// 处理通知点击事件
  void _onNotificationTapped(NotificationResponse response) {
    _logger.d('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final type = data['type'] as String?;
        
        switch (type) {
          case 'stock_signal':
            // 处理股票信号通知点击
            _handleStockSignalTap(data);
            break;
          case 'price_alert':
            // 处理价格提醒通知点击
            _handlePriceAlertTap(data);
            break;
          default:
            break;
        }
      } catch (e) {
        _logger.e('Error parsing notification payload: $e');
      }
    }
  }

  /// 发送股票信号通知
  Future<void> sendStockSignalNotification(AnalysisResult result) async {
    if (!_isInitialized) await init();

    final payload = jsonEncode({
      'type': 'stock_signal',
      'code': result.code,
      'name': result.name,
      'score': result.score,
    });

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stock_signals',
      '股票信号',
      channelDescription: '股票技术分析信号通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1976D2),
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      result.code.hashCode, // 使用股票代码的hash作为ID
      '🚀 ${result.name} 发现信号',
      _buildSignalMessage(result),
      notificationDetails,
      payload: payload,
    );

    _logger.i('Stock signal notification sent for ${result.code}');
  }

  /// 发送价格提醒通知
  Future<void> sendPriceAlertNotification(
    String code,
    String name,
    double currentPrice,
    double targetPrice,
    String alertType,
  ) async {
    if (!_isInitialized) await init();

    final payload = jsonEncode({
      'type': 'price_alert',
      'code': code,
      'name': name,
      'currentPrice': currentPrice,
      'targetPrice': targetPrice,
      'alertType': alertType,
    });

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'price_alerts',
      '价格提醒',
      channelDescription: '股票价格变动提醒',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1976D2),
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final title = alertType == 'above' ? '📈 价格突破提醒' : '📉 价格跌破提醒';
    final message = '$name 当前价格 ¥${currentPrice.toStringAsFixed(2)}，${alertType == 'above' ? '突破' : '跌破'}目标价 ¥${targetPrice.toStringAsFixed(2)}';

    await _flutterLocalNotificationsPlugin.show(
      '${code}_price'.hashCode,
      title,
      message,
      notificationDetails,
      payload: payload,
    );

    _logger.i('Price alert notification sent for $code');
  }

  /// 发送系统通知
  Future<void> sendSystemNotification(
    String title,
    String message, {
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'system_notifications',
      '系统通知',
      channelDescription: '应用系统通知',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1976D2),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
      notificationDetails,
      payload: payload,
    );

    _logger.i('System notification sent: $title');
  }

  /// 取消指定通知
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 构建信号通知消息
  String _buildSignalMessage(AnalysisResult result) {
    final signals = <String>[];
    
    if (result.hasYinBeiLiang) {
      signals.add('阴背量');
    }
    if (result.breakoutSignal) {
      signals.add('突破信号');
    }
    if (result.volRatio >= 1.5) {
      signals.add('放量');
    }

    final signalText = signals.isNotEmpty ? signals.join('、') : '技术信号';
    return '$signalText，评分: ${result.score.toStringAsFixed(1)}，量比: ${result.volRatio.toStringAsFixed(1)}x';
  }

  /// 处理股票信号通知点击
  void _handleStockSignalTap(Map<String, dynamic> data) {
    // TODO: 导航到股票详情页面
    _logger.d('Stock signal tapped: ${data['code']}');
  }

  /// 处理价格提醒通知点击
  void _handlePriceAlertTap(Map<String, dynamic> data) {
    // TODO: 导航到股票详情页面
    _logger.d('Price alert tapped: ${data['code']}');
  }

  /// 检查通知权限
  Future<bool> checkNotificationPermission() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      return granted ?? false;
    }
    
    return false;
  }

  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestPermission();
      return granted ?? false;
    }
    
    return false;
  }
}
