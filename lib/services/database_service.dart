import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_data.dart';

/// SQLite数据库服务
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_monitor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// 创建数据表
  Future<void> _createTables(Database db, int version) async {
    // 股票基础信息表
    await db.execute('''
      CREATE TABLE stock_info (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        market TEXT NOT NULL,
        industry TEXT,
        total_market_value REAL,
        circulation_market_value REAL,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // K线数据表
    await db.execute('''
      CREATE TABLE kline_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        date TEXT NOT NULL,
        open_price REAL NOT NULL,
        high_price REAL NOT NULL,
        low_price REAL NOT NULL,
        close_price REAL NOT NULL,
        volume REAL NOT NULL,
        amount REAL NOT NULL,
        amplitude REAL,
        change_rate REAL,
        change_amount REAL,
        turnover_rate REAL,
        created_at INTEGER,
        UNIQUE(code, date)
      )
    ''');

    // 分析结果表
    await db.execute('''
      CREATE TABLE analysis_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        has_yin_bei_liang INTEGER NOT NULL,
        vol_multiple REAL NOT NULL,
        band_pct REAL NOT NULL,
        vol_ratio REAL NOT NULL,
        breakout_signal INTEGER NOT NULL,
        close_near_high REAL NOT NULL,
        moving_averages TEXT NOT NULL,
        score REAL NOT NULL,
        created_at INTEGER,
        UNIQUE(code, analysis_date)
      )
    ''');

    // 监控配置表
    await db.execute('''
      CREATE TABLE monitor_config (
        id INTEGER PRIMARY KEY,
        vol_mult REAL NOT NULL,
        band_pct REAL NOT NULL,
        vol_ratio_min REAL NOT NULL,
        amp_max REAL NOT NULL,
        lookback INTEGER NOT NULL,
        min_avg_amount_20 REAL NOT NULL,
        eod_break_min_pct REAL NOT NULL,
        eod_close_near_high_min REAL NOT NULL,
        top_n INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // 监控列表表
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        added_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        notes TEXT,
        created_at INTEGER
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_kline_code_date ON kline_data(code, date)');
    await db.execute('CREATE INDEX idx_analysis_code_date ON analysis_results(code, analysis_date)');
  }

  /// 数据库升级
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < newVersion) {
      // 添加新字段或表的逻辑
    }
  }

  /// 保存股票基础信息
  Future<void> saveStockInfo(StockInfo stockInfo) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      'stock_info',
      {
        'code': stockInfo.code,
        'name': stockInfo.name,
        'market': stockInfo.market,
        'industry': stockInfo.industry,
        'total_market_value': stockInfo.totalMarketValue,
        'circulation_market_value': stockInfo.circulationMarketValue,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取股票基础信息
  Future<StockInfo?> getStockInfo(String code) async {
    final db = await database;
    final result = await db.query(
      'stock_info',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return StockInfo(
      code: row['code'] as String,
      name: row['name'] as String,
      market: row['market'] as String,
      industry: row['industry'] as String? ?? '',
      totalMarketValue: row['total_market_value'] as double? ?? 0,
      circulationMarketValue: row['circulation_market_value'] as double? ?? 0,
    );
  }

  /// 批量保存K线数据
  Future<void> saveKlineData(List<StockKlineData> klineDataList) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final kline in klineDataList) {
      batch.insert(
        'kline_data',
        {
          'code': kline.code,
          'date': kline.date.toIso8601String().split('T')[0],
          'open_price': kline.open,
          'high_price': kline.high,
          'low_price': kline.low,
          'close_price': kline.close,
          'volume': kline.volume,
          'amount': kline.amount,
          'amplitude': kline.amplitude,
          'change_rate': kline.changeRate,
          'change_amount': kline.changeAmount,
          'turnover_rate': kline.turnoverRate,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  /// 获取K线数据
  Future<List<StockKlineData>> getKlineData(
    String code, {
    int limit = 500,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = 'code = ?';
    List<dynamic> whereArgs = [code];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final result = await db.query(
      'kline_data',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date ASC',
      limit: limit,
    );

    return result.map((row) {
      return StockKlineData(
        code: row['code'] as String,
        name: '', // 需要从stock_info表关联获取
        date: DateTime.parse(row['date'] as String),
        open: row['open_price'] as double,
        high: row['high_price'] as double,
        low: row['low_price'] as double,
        close: row['close_price'] as double,
        volume: row['volume'] as double,
        amount: row['amount'] as double,
        amplitude: row['amplitude'] as double? ?? 0,
        changeRate: row['change_rate'] as double? ?? 0,
        changeAmount: row['change_amount'] as double? ?? 0,
        turnoverRate: row['turnover_rate'] as double? ?? 0,
      );
    }).toList();
  }

  /// 保存分析结果
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'analysis_results',
      {
        'code': result.code,
        'name': result.name,
        'analysis_date': result.analysisDate.toIso8601String().split('T')[0],
        'has_yin_bei_liang': result.hasYinBeiLiang ? 1 : 0,
        'vol_multiple': result.volMultiple,
        'band_pct': result.bandPct,
        'vol_ratio': result.volRatio,
        'breakout_signal': result.breakoutSignal ? 1 : 0,
        'close_near_high': result.closeNearHigh,
        'moving_averages': jsonEncode(result.movingAverages),
        'score': result.score,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取最新分析结果
  Future<List<AnalysisResult>> getLatestAnalysisResults({int limit = 50}) async {
    final db = await database;
    final result = await db.query(
      'analysis_results',
      orderBy: 'score DESC, analysis_date DESC',
      limit: limit,
    );

    return result.map((row) {
      return AnalysisResult(
        code: row['code'] as String,
        name: row['name'] as String,
        analysisDate: DateTime.parse(row['analysis_date'] as String),
        hasYinBeiLiang: (row['has_yin_bei_liang'] as int) == 1,
        volMultiple: row['vol_multiple'] as double,
        bandPct: row['band_pct'] as double,
        volRatio: row['vol_ratio'] as double,
        breakoutSignal: (row['breakout_signal'] as int) == 1,
        closeNearHigh: row['close_near_high'] as double,
        movingAverages: Map<String, double>.from(
          jsonDecode(row['moving_averages'] as String),
        ),
        score: row['score'] as double,
      );
    }).toList();
  }

  /// 保存监控配置
  Future<void> saveMonitorConfig(MonitorConfig config) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'monitor_config',
      {
        'id': 1, // 单例配置
        'vol_mult': config.volMult,
        'band_pct': config.bandPct,
        'vol_ratio_min': config.volRatioMin,
        'amp_max': config.ampMax,
        'lookback': config.lookback,
        'min_avg_amount_20': config.minAvgAmount20,
        'eod_break_min_pct': config.eodBreakMinPct,
        'eod_close_near_high_min': config.eodCloseNearHighMin,
        'top_n': config.topN,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取监控配置
  Future<MonitorConfig> getMonitorConfig() async {
    final db = await database;
    final result = await db.query(
      'monitor_config',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) {
      // 返回默认配置
      return MonitorConfig();
    }

    final row = result.first;
    return MonitorConfig(
      volMult: row['vol_mult'] as double,
      bandPct: row['band_pct'] as double,
      volRatioMin: row['vol_ratio_min'] as double,
      ampMax: row['amp_max'] as double,
      lookback: row['lookback'] as int,
      minAvgAmount20: row['min_avg_amount_20'] as double,
      eodBreakMinPct: row['eod_break_min_pct'] as double,
      eodCloseNearHighMin: row['eod_close_near_high_min'] as double,
      topN: row['top_n'] as int,
    );
  }

  /// 清理过期数据
  Future<void> cleanupOldData({int keepDays = 90}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    final cutoffDateStr = cutoffDate.toIso8601String().split('T')[0];

    // 清理过期的K线数据
    await db.delete(
      'kline_data',
      where: 'date < ?',
      whereArgs: [cutoffDateStr],
    );

    // 清理过期的分析结果
    await db.delete(
      'analysis_results',
      where: 'analysis_date < ?',
      whereArgs: [cutoffDateStr],
    );
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
