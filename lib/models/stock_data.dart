// 移除 json_annotation 依赖，使用手动序列化

/// 股票K线数据模型
class StockKlineData {
  final String code;        // 股票代码
  final String name;        // 股票名称
  final DateTime date;      // 日期
  final double open;        // 开盘价
  final double high;        // 最高价
  final double low;         // 最低价
  final double close;       // 收盘价
  final double volume;      // 成交量
  final double amount;      // 成交额
  final double amplitude;   // 振幅
  final double changeRate;  // 涨跌幅
  final double changeAmount; // 涨跌额
  final double turnoverRate; // 换手率

  StockKlineData({
    required this.code,
    required this.name,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.amount,
    required this.amplitude,
    required this.changeRate,
    required this.changeAmount,
    required this.turnoverRate,
  });

  factory StockKlineData.fromJson(Map<String, dynamic> json) => StockKlineData(
    code: json['code'] as String,
    name: json['name'] as String,
    date: DateTime.parse(json['date'] as String),
    open: (json['open'] as num).toDouble(),
    high: (json['high'] as num).toDouble(),
    low: (json['low'] as num).toDouble(),
    close: (json['close'] as num).toDouble(),
    volume: (json['volume'] as num).toDouble(),
    amount: (json['amount'] as num).toDouble(),
    amplitude: (json['amplitude'] as num).toDouble(),
    changeRate: (json['changeRate'] as num).toDouble(),
    changeAmount: (json['changeAmount'] as num).toDouble(),
    turnoverRate: (json['turnoverRate'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'date': date.toIso8601String(),
    'open': open,
    'high': high,
    'low': low,
    'close': close,
    'volume': volume,
    'amount': amount,
    'amplitude': amplitude,
    'changeRate': changeRate,
    'changeAmount': changeAmount,
    'turnoverRate': turnoverRate,
  };

  /// 从东方财富API数据转换
  factory StockKlineData.fromEastmoneyData(String code, String name, List<String> data) {
    return StockKlineData(
      code: code,
      name: name,
      date: DateTime.parse(data[0]),
      open: double.parse(data[1]),
      close: double.parse(data[2]),
      high: double.parse(data[3]),
      low: double.parse(data[4]),
      volume: double.parse(data[5]),
      amount: double.parse(data[6]),
      amplitude: double.parse(data[7]),
      changeRate: double.parse(data[8]),
      changeAmount: double.parse(data[9]),
      turnoverRate: double.parse(data[10]),
    );
  }
}

/// 股票基础信息
class StockInfo {
  final String code;
  final String name;
  final String market; // 市场：SH/SZ
  final String industry; // 行业
  final double totalMarketValue; // 总市值
  final double circulationMarketValue; // 流通市值

  StockInfo({
    required this.code,
    required this.name,
    required this.market,
    required this.industry,
    required this.totalMarketValue,
    required this.circulationMarketValue,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) => StockInfo(
    code: json['code'] as String,
    name: json['name'] as String,
    market: json['market'] as String,
    industry: json['industry'] as String,
    totalMarketValue: (json['totalMarketValue'] as num).toDouble(),
    circulationMarketValue: (json['circulationMarketValue'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'market': market,
    'industry': industry,
    'totalMarketValue': totalMarketValue,
    'circulationMarketValue': circulationMarketValue,
  };

  /// 转换为东方财富API的secid格式
  String get secId {
    if (code.startsWith('6')) {
      return '1.$code'; // 上海
    } else {
      return '0.$code'; // 深圳
    }
  }
}

/// 技术分析结果
class AnalysisResult {
  final String code;
  final String name;
  final DateTime analysisDate;
  final bool hasYinBeiLiang; // 是否有阴背量信号
  final double volMultiple; // 成交量倍数
  final double bandPct; // 压力带百分比
  final double volRatio; // 成交量比率
  final bool breakoutSignal; // 突破信号
  final double closeNearHigh; // 收盘价接近最高价程度
  final Map<String, double> movingAverages; // 移动平均线
  final double score; // 综合评分

  AnalysisResult({
    required this.code,
    required this.name,
    required this.analysisDate,
    required this.hasYinBeiLiang,
    required this.volMultiple,
    required this.bandPct,
    required this.volRatio,
    required this.breakoutSignal,
    required this.closeNearHigh,
    required this.movingAverages,
    required this.score,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    code: json['code'] as String,
    name: json['name'] as String,
    analysisDate: DateTime.parse(json['analysisDate'] as String),
    hasYinBeiLiang: json['hasYinBeiLiang'] as bool,
    volMultiple: (json['volMultiple'] as num).toDouble(),
    bandPct: (json['bandPct'] as num).toDouble(),
    volRatio: (json['volRatio'] as num).toDouble(),
    breakoutSignal: json['breakoutSignal'] as bool,
    closeNearHigh: (json['closeNearHigh'] as num).toDouble(),
    movingAverages: Map<String, double>.from(json['movingAverages'] as Map),
    score: (json['score'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'analysisDate': analysisDate.toIso8601String(),
    'hasYinBeiLiang': hasYinBeiLiang,
    'volMultiple': volMultiple,
    'bandPct': bandPct,
    'volRatio': volRatio,
    'breakoutSignal': breakoutSignal,
    'closeNearHigh': closeNearHigh,
    'movingAverages': movingAverages,
    'score': score,
  };
}

/// 监控配置参数
class MonitorConfig {
  final double volMult; // 成交量倍数阈值
  final double bandPct; // 压力带百分比
  final double volRatioMin; // 最小成交量比率
  final double ampMax; // 最大振幅
  final int lookback; // 回看天数
  final double minAvgAmount20; // 20日平均成交额最小值
  final double eodBreakMinPct; // 尾盘突破最小百分比
  final double eodCloseNearHighMin; // 收盘价接近最高价最小值
  final int topN; // 显示前N只股票

  MonitorConfig({
    this.volMult = 2.5,
    this.bandPct = 0.03,
    this.volRatioMin = 1.2,
    this.ampMax = 0.25,
    this.lookback = 30,
    this.minAvgAmount20 = 2e8,
    this.eodBreakMinPct = 0.005,
    this.eodCloseNearHighMin = 0.6,
    this.topN = 50,
  });

  factory MonitorConfig.fromJson(Map<String, dynamic> json) => MonitorConfig(
    volMult: (json['volMult'] as num?)?.toDouble() ?? 2.5,
    bandPct: (json['bandPct'] as num?)?.toDouble() ?? 0.03,
    volRatioMin: (json['volRatioMin'] as num?)?.toDouble() ?? 1.2,
    ampMax: (json['ampMax'] as num?)?.toDouble() ?? 0.25,
    lookback: (json['lookback'] as int?) ?? 30,
    minAvgAmount20: (json['minAvgAmount20'] as num?)?.toDouble() ?? 2e8,
    eodBreakMinPct: (json['eodBreakMinPct'] as num?)?.toDouble() ?? 0.005,
    eodCloseNearHighMin: (json['eodCloseNearHighMin'] as num?)?.toDouble() ?? 0.6,
    topN: (json['topN'] as int?) ?? 50,
  );

  Map<String, dynamic> toJson() => {
    'volMult': volMult,
    'bandPct': bandPct,
    'volRatioMin': volRatioMin,
    'ampMax': ampMax,
    'lookback': lookback,
    'minAvgAmount20': minAvgAmount20,
    'eodBreakMinPct': eodBreakMinPct,
    'eodCloseNearHighMin': eodCloseNearHighMin,
    'topN': topN,
  };
}
