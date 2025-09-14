import 'package:flutter/material.dart';
import '../models/stock_data.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/analysis_service.dart';

/// 股票数据提供者
class StockProvider extends ChangeNotifier {
  final EastmoneyApiService _apiService = EastmoneyApiService();
  final DatabaseService _databaseService = DatabaseService();
  final AnalysisService _analysisService = AnalysisService();
  
  List<AnalysisResult> _analysisResults = [];
  MonitorConfig _config = MonitorConfig();
  bool _isLoading = false;
  String? _error;

  List<AnalysisResult> get analysisResults => _analysisResults;
  MonitorConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载分析结果
  Future<void> loadAnalysisResults() async {
    _setLoading(true);
    _error = null;
    
    try {
      _analysisResults = await _databaseService.getLatestAnalysisResults();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 加载配置
  Future<void> loadConfig() async {
    try {
      _config = await _databaseService.getMonitorConfig();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 保存配置
  Future<void> saveConfig(MonitorConfig newConfig) async {
    try {
      await _databaseService.saveMonitorConfig(newConfig);
      _config = newConfig;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadAnalysisResults();
  }

  /// 分析股票
  Future<void> analyzeStock(String code) async {
    try {
      _setLoading(true);
      
      // 获取K线数据
      final klineData = await _apiService.getKlineData(code, count: 200);
      
      if (klineData.length < 120) {
        throw Exception('数据不足，无法进行分析');
      }

      // 执行分析
      final result = _analysisService.analyzeYinBeiLiang(klineData, _config);
      
      // 保存结果
      await _databaseService.saveAnalysisResult(result);
      
      // 更新列表
      await loadAnalysisResults();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
