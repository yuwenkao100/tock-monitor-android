import 'package:flutter_test/flutter_test.dart';
import 'package:stock_monitor/models/stock_data.dart';
import 'package:stock_monitor/services/analysis_service.dart';

void main() {
  group('AnalysisService Tests', () {
    late AnalysisService analysisService;
    late List<StockKlineData> testKlineData;

    setUp(() {
      analysisService = AnalysisService();
      testKlineData = _generateTestKlineData();
    });

    test('calculateMA should return correct moving averages', () {
      final ma5 = analysisService.calculateMA(testKlineData, 5);
      final ma20 = analysisService.calculateMA(testKlineData, 20);

      expect(ma5.length, equals(testKlineData.length - 4));
      expect(ma20.length, equals(testKlineData.length - 19));
      
      // 验证MA5的第一个值
      final expectedMA5 = testKlineData.take(5).map((e) => e.close).reduce((a, b) => a + b) / 5;
      expect(ma5.first, closeTo(expectedMA5, 0.01));
    });

    test('calculateVMA should return correct volume moving averages', () {
      final vma20 = analysisService.calculateVMA(testKlineData, 20);

      expect(vma20.length, equals(testKlineData.length - 19));
      
      // 验证VMA20的第一个值
      final expectedVMA20 = testKlineData.take(20).map((e) => e.volume).reduce((a, b) => a + b) / 20;
      expect(vma20.first, closeTo(expectedVMA20, 0.01));
    });

    test('analyzeYinBeiLiang should detect signals correctly', () {
      final config = MonitorConfig(
        volMult: 2.0,
        bandPct: 0.03,
        volRatioMin: 1.2,
        ampMax: 0.25,
        lookback: 30,
      );

      final result = analysisService.analyzeYinBeiLiang(testKlineData, config);

      expect(result.code, equals('000001'));
      expect(result.name, equals('测试股票'));
      expect(result.score, greaterThanOrEqualTo(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.movingAverages, isNotEmpty);
    });

    test('checkMonitorConditions should validate basic conditions', () {
      final config = MonitorConfig();
      
      // 测试数据不足的情况
      final shortData = testKlineData.take(50).toList();
      expect(analysisService.checkMonitorConditions(shortData, config), isFalse);
      
      // 测试正常数据
      expect(analysisService.checkMonitorConditions(testKlineData, config), isTrue);
    });

    test('analyzeYinBeiLiang should handle edge cases', () {
      final config = MonitorConfig();
      
      // 测试数据不足的情况
      expect(() {
        final shortData = testKlineData.take(50).toList();
        analysisService.analyzeYinBeiLiang(shortData, config);
      }, throwsException);
    });
  });
}

/// 生成测试用的K线数据
List<StockKlineData> _generateTestKlineData() {
  final data = <StockKlineData>[];
  final baseDate = DateTime(2024, 1, 1);
  
  for (int i = 0; i < 200; i++) {
    final date = baseDate.add(Duration(days: i));
    final basePrice = 10.0 + (i * 0.1); // 模拟价格上涨趋势
    final volatility = 0.5; // 波动率
    
    // 模拟价格波动
    final open = basePrice + (i % 3 - 1) * volatility;
    final close = open + (i % 5 - 2) * volatility * 0.5;
    final high = [open, close].reduce((a, b) => a > b ? a : b) + volatility * 0.3;
    final low = [open, close].reduce((a, b) => a < b ? a : b) - volatility * 0.3;
    
    // 模拟成交量（偶尔有放量）
    final baseVolume = 1000000.0;
    final volume = baseVolume * (1 + (i % 10 == 0 ? 2.0 : 0.2)); // 每10天放量一次
    
    data.add(StockKlineData(
      code: '000001',
      name: '测试股票',
      date: date,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      amount: volume * close,
      amplitude: (high - low) / low,
      changeRate: i > 0 ? (close - data[i-1].close) / data[i-1].close : 0,
      changeAmount: i > 0 ? close - data[i-1].close : 0,
      turnoverRate: 0.05,
    ));
  }
  
  return data;
}

/// 性能测试
void performanceTests() {
  group('Performance Tests', () {
    test('analyzeYinBeiLiang performance test', () {
      final analysisService = AnalysisService();
      final testData = _generateTestKlineData();
      final config = MonitorConfig();
      
      final stopwatch = Stopwatch()..start();
      
      // 执行100次分析
      for (int i = 0; i < 100; i++) {
        analysisService.analyzeYinBeiLiang(testData, config);
      }
      
      stopwatch.stop();
      
      // 平均每次分析应该在10ms以内
      final avgTime = stopwatch.elapsedMilliseconds / 100;
      expect(avgTime, lessThan(10));
      
      print('Average analysis time: ${avgTime.toStringAsFixed(2)}ms');
    });

    test('calculateMA performance test', () {
      final analysisService = AnalysisService();
      final testData = _generateTestKlineData();
      
      final stopwatch = Stopwatch()..start();
      
      // 执行1000次MA计算
      for (int i = 0; i < 1000; i++) {
        analysisService.calculateMA(testData, 20);
      }
      
      stopwatch.stop();
      
      // 平均每次计算应该在1ms以内
      final avgTime = stopwatch.elapsedMilliseconds / 1000;
      expect(avgTime, lessThan(1));
      
      print('Average MA calculation time: ${avgTime.toStringAsFixed(3)}ms');
    });
  });
}
