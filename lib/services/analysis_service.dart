import 'dart:math';
import '../models/stock_data.dart';

/// 技术分析服务
class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  /// 计算移动平均线
  /// [data] K线数据列表
  /// [period] 周期
  List<double> calculateMA(List<StockKlineData> data, int period) {
    if (data.length < period) return [];
    
    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += data[j].close;
      }
      result.add(sum / period);
    }
    return result;
  }

  /// 计算成交量移动平均线
  List<double> calculateVMA(List<StockKlineData> data, int period) {
    if (data.length < period) return [];
    
    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += data[j].volume;
      }
      result.add(sum / period);
    }
    return result;
  }

  /// 阴背量分析
  /// 移植自Python的monitor_watchlist.py中的阴背量算法
  AnalysisResult analyzeYinBeiLiang(
    List<StockKlineData> klineData,
    MonitorConfig config,
  ) {
    if (klineData.length < config.lookback + 20) {
      throw Exception('数据不足，需要至少${config.lookback + 20}条K线数据');
    }

    final latestData = klineData.last;
    final code = latestData.code;
    final name = latestData.name;

    // 计算各种移动平均线
    final ma5 = calculateMA(klineData, 5);
    final ma10 = calculateMA(klineData, 10);
    final ma20 = calculateMA(klineData, 20);
    final ma60 = calculateMA(klineData, 60);
    final ma120 = calculateMA(klineData, 120);
    // final vma5 = calculateVMA(klineData, 5);  // 暂时未使用
    // final vma10 = calculateVMA(klineData, 10);  // 暂时未使用
    final vma20 = calculateVMA(klineData, 20);

    // 获取最新的移动平均线值
    final currentMA = <String, double>{
      'MA5': ma5.isNotEmpty ? ma5.last : 0,
      'MA10': ma10.isNotEmpty ? ma10.last : 0,
      'MA20': ma20.isNotEmpty ? ma20.last : 0,
      'MA60': ma60.isNotEmpty ? ma60.last : 0,
      'MA120': ma120.isNotEmpty ? ma120.last : 0,
    };

    // 检查阴背量条件
    bool hasYinBeiLiang = false;
    double volMultiple = 0;
    double volRatio = 0;

    if (vma20.isNotEmpty) {
      volRatio = latestData.volume / vma20.last;
      
      // 在回看期内寻找阴背量信号
      for (int i = max(0, klineData.length - config.lookback); 
           i < klineData.length - 1; i++) {
        final dayData = klineData[i];
        
        // 阴线条件：收盘价 < 开盘价
        if (dayData.close < dayData.open) {
          // 成交量倍数检查
          if (i < vma20.length) {
            final dayVolRatio = dayData.volume / vma20[i];
            if (dayVolRatio >= config.volMult) {
              volMultiple = max(volMultiple, dayVolRatio);
              hasYinBeiLiang = true;
            }
          }
        }
      }
    }

    // 压力带分析
    final bandPct = config.bandPct;
    // final upperBand = latestData.close * (1 + bandPct);  // 暂时未使用
    // final lowerBand = latestData.close * (1 - bandPct);  // 暂时未使用

    // 突破信号检查
    bool breakoutSignal = false;
    if (klineData.length >= 20) {
      final recent20High = klineData
          .skip(klineData.length - 20)
          .map((e) => e.high)
          .reduce(max);
      
      final breakoutPct = (latestData.close - recent20High) / recent20High;
      breakoutSignal = breakoutPct >= config.eodBreakMinPct;
    }

    // 收盘价接近最高价程度
    final closeNearHigh = latestData.high > latestData.low
        ? (latestData.close - latestData.low) / (latestData.high - latestData.low)
        : 0.0;

    // 计算20日平均成交额
    double avgAmount20 = 0;
    if (klineData.length >= 20) {
      final recent20Amount = klineData
          .skip(klineData.length - 20)
          .map((e) => e.amount)
          .reduce((a, b) => a + b);
      avgAmount20 = recent20Amount / 20;
    }

    // 计算20日振幅
    double amplitude20 = 0;
    if (klineData.length >= 20) {
      final recent20 = klineData.skip(klineData.length - 20).toList();
      final maxHigh = recent20.map((e) => e.high).reduce(max);
      final minLow = recent20.map((e) => e.low).reduce(min);
      amplitude20 = (maxHigh - minLow) / minLow;
    }

    // 综合评分计算
    double score = 0;
    if (hasYinBeiLiang) score += 30;
    if (volRatio >= config.volRatioMin) score += 20;
    if (breakoutSignal) score += 25;
    if (closeNearHigh >= config.eodCloseNearHighMin) score += 15;
    if (avgAmount20 >= config.minAvgAmount20) score += 10;

    // 质量过滤条件
    final passQualityFilter = 
        avgAmount20 >= config.minAvgAmount20 &&
        amplitude20 <= config.ampMax &&
        closeNearHigh >= config.eodCloseNearHighMin;

    if (!passQualityFilter) {
      score *= 0.5; // 不满足质量条件的股票评分减半
    }

    return AnalysisResult(
      code: code,
      name: name,
      analysisDate: DateTime.now(),
      hasYinBeiLiang: hasYinBeiLiang,
      volMultiple: volMultiple,
      bandPct: bandPct,
      volRatio: volRatio,
      breakoutSignal: breakoutSignal,
      closeNearHigh: closeNearHigh,
      movingAverages: currentMA,
      score: score,
    );
  }

  /// 批量分析股票列表
  Future<List<AnalysisResult>> batchAnalyze(
    List<String> codes,
    MonitorConfig config,
  ) async {
    final results = <AnalysisResult>[];
    
    // 这里应该并发获取数据和分析，为了简化先用串行处理
    for (final code in codes) {
      try {
        // 获取K线数据（这里需要调用API服务）
        // final klineData = await EastmoneyApiService().getKlineData(code);
        // final result = analyzeYinBeiLiang(klineData, config);
        // results.add(result);
      } catch (e) {
        // 记录错误但继续处理其他股票
        print('分析股票 $code 失败: $e');
      }
    }

    // 按评分排序
    results.sort((a, b) => b.score.compareTo(a.score));
    
    // 返回前N只股票
    return results.take(config.topN).toList();
  }

  /// 检查股票是否满足监控条件
  bool checkMonitorConditions(
    List<StockKlineData> klineData,
    MonitorConfig config,
  ) {
    if (klineData.isEmpty) return false;

    final latest = klineData.last;
    
    // 基本条件检查
    if (klineData.length < 120) return false; // 需要足够的历史数据

    final ma60 = calculateMA(klineData, 60);
    final ma120 = calculateMA(klineData, 120);
    
    if (ma60.isEmpty || ma120.isEmpty) return false;

    // 核心条件：收盘价 > MA60 且 > MA120
    final currentMA60 = ma60.last;
    final currentMA120 = ma120.last;
    
    if (latest.close <= currentMA60 || latest.close <= currentMA120) {
      return false;
    }

    // MA60上行检查
    if (ma60.length >= 5) {
      final ma60_5daysAgo = ma60[ma60.length - 5];
      if (currentMA60 <= ma60_5daysAgo) return false;
    }

    return true;
  }
}
