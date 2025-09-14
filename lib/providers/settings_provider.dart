import 'package:flutter/material.dart';

/// 设置提供者
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _enableNotifications = true;
  bool _enableAutoRefresh = true;
  int _refreshInterval = 300; // 5分钟

  ThemeMode get themeMode => _themeMode;
  bool get enableNotifications => _enableNotifications;
  bool get enableAutoRefresh => _enableAutoRefresh;
  int get refreshInterval => _refreshInterval;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setEnableNotifications(bool enable) {
    _enableNotifications = enable;
    notifyListeners();
  }

  void setEnableAutoRefresh(bool enable) {
    _enableAutoRefresh = enable;
    notifyListeners();
  }

  void setRefreshInterval(int interval) {
    _refreshInterval = interval;
    notifyListeners();
  }
}
