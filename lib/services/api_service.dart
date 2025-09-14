import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/stock_data.dart';
import 'network_manager.dart';
import 'database_service.dart';

/// 东方财富API服务
class EastmoneyApiService {
  static final EastmoneyApiService _instance = EastmoneyApiService._internal();
  factory EastmoneyApiService() => _instance;
  EastmoneyApiService._internal();

  final NetworkManager _networkManager = NetworkManager();
  final DatabaseService _databaseService = DatabaseService();
  final Logger _logger = Logger();

  /// 初始化API服务
  Future<void> init() async {
    await _networkManager.init();
    _logger.i('EastmoneyApiService initialized');
  }

  /// 获取股票K线数据
  /// [code] 股票代码
  /// [period] 周期：101=日线, 102=周线, 103=月线
  /// [count] 获取数据条数，默认500
  /// [useCache] 是否使用缓存，默认true
  Future<List<StockKlineData>> getKlineData(
    String code, {
    int period = 101,
    int count = 500,
    bool useCache = true,
  }) async {
    try {
      // 先尝试从缓存获取数据
      if (useCache) {
        final cachedData = await _databaseService.getKlineData(code, limit: count);
        if (cachedData.isNotEmpty) {
          // 检查数据是否足够新（当天或昨天的数据）
          final latestDate = cachedData.last.date;
          final now = DateTime.now();
          final isRecent = now.difference(latestDate).inDays <= 1;

          if (isRecent && cachedData.length >= count * 0.8) {
            _logger.d('Using cached data for $code');
            return cachedData;
          }
        }
      }

      final secId = _codeToSecId(code);
      final url = 'https://push2his.eastmoney.com/api/qt/stock/kline/get';

      final params = {
        'secid': secId,
        'ut': 'fa5fd1943c7b386f172d6893dbfba10b',
        'fields1': 'f1,f2,f3,f4,f5,f6',
        'fields2': 'f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61',
        'klt': period.toString(),
        'fqt': '1', // 前复权
        'end': '20500101',
        'lmt': count.toString(),
      };

      final response = await _networkManager.get(url, queryParameters: params);
      final data = response.data;

      if (data['rc'] != 0) {
        throw Exception('API返回错误: ${data['rt']}');
      }

      final klines = data['data']['klines'] as List<dynamic>;
      final stockName = data['data']['name'] as String;

      final klineDataList = klines.map((kline) {
        final parts = (kline as String).split(',');
        return StockKlineData.fromEastmoneyData(code, stockName, parts);
      }).toList();

      // 缓存数据到本地数据库
      if (klineDataList.isNotEmpty) {
        await _databaseService.saveKlineData(klineDataList);

        // 保存股票基础信息
        final stockInfo = StockInfo(
          code: code,
          name: stockName,
          market: code.startsWith('6') ? 'SH' : 'SZ',
          industry: '',
          totalMarketValue: 0,
          circulationMarketValue: 0,
        );
        await _databaseService.saveStockInfo(stockInfo);
      }

      return klineDataList;

    } on DioException catch (e) {
      _logger.e('网络请求失败: ${NetworkErrorHandler.getErrorMessage(e)}');

      // 网络错误时尝试返回缓存数据
      if (NetworkErrorHandler.isNetworkError(e) && useCache) {
        final cachedData = await _databaseService.getKlineData(code, limit: count);
        if (cachedData.isNotEmpty) {
          _logger.w('Network failed, using cached data for $code');
          return cachedData;
        }
      }

      rethrow;
    } catch (e) {
      _logger.e('获取K线数据失败: $e');
      rethrow;
    }
  }

  /// 获取涨停板数据
  Future<List<Map<String, dynamic>>> getLimitUpData() async {
    try {
      const url = 'https://push2.eastmoney.com/api/qt/clist/get';
      
      final params = {
        'pn': '1',
        'pz': '50',
        'po': '1',
        'np': '1',
        'ut': 'bd1d9ddb04089700cf9c27f6f7426281',
        'fltt': '2',
        'invt': '2',
        'wbp2u': '|0|0|0|web',
        'fid': 'f3',
        'fs': 'm:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23,m:0+t:81+s:2048',
        'fields': 'f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f12,f13,f14,f15,f16,f17,f18,f20,f21,f23,f24,f25,f22,f11,f62,f128,f136,f115,f152',
      };

      final response = await _networkManager.get(url, queryParameters: params);
      final data = response.data;

      if (data['rc'] != 0) {
        throw Exception('获取涨停数据失败');
      }

      final diff = data['data']['diff'] as List<dynamic>;
      return diff.cast<Map<String, dynamic>>();

    } catch (e) {
      _logger.e('获取涨停数据失败: $e');
      rethrow;
    }
  }

  /// 获取股票基础信息
  Future<StockInfo> getStockInfo(String code) async {
    try {
      final secId = _codeToSecId(code);
      const url = 'https://push2.eastmoney.com/api/qt/stock/get';
      
      final params = {
        'ut': 'fa5fd1943c7b386f172d6893dbfba10b',
        'invt': '2',
        'fltt': '2',
        'fields': 'f43,f57,f58,f169,f170,f46,f44,f51,f168,f47,f164,f163,f116,f60,f45,f52,f50,f48,f167,f117,f71,f161,f49,f530,f135,f136,f137,f138,f139,f141,f142,f144,f145,f147,f148,f140,f143,f146,f149,f55,f62,f162,f92,f173,f104,f105,f84,f85,f183,f184,f185,f186,f187,f188,f189,f190,f191,f192,f107,f111,f86,f177,f78,f110,f262,f263,f264,f267,f268,f250,f251,f252,f253,f254,f255,f256,f257,f258,f266,f269,f270,f271,f273,f274,f275,f127,f199,f128,f193,f196,f194,f195,f197,f80,f280,f281,f282,f284,f285,f286,f287,f292',
        'secid': secId,
      };

      final response = await _networkManager.get(url, queryParameters: params);
      final data = response.data;

      if (data['rc'] != 0) {
        throw Exception('获取股票信息失败');
      }

      final stockData = data['data'];
      return StockInfo(
        code: code,
        name: stockData['f58'] ?? '',
        market: code.startsWith('6') ? 'SH' : 'SZ',
        industry: stockData['f127'] ?? '',
        totalMarketValue: (stockData['f116'] ?? 0).toDouble(),
        circulationMarketValue: (stockData['f117'] ?? 0).toDouble(),
      );

    } catch (e) {
      _logger.e('获取股票信息失败: $e');
      rethrow;
    }
  }

  /// 批量获取股票实时数据
  Future<List<Map<String, dynamic>>> getBatchRealTimeData(List<String> codes) async {
    try {
      final secIds = codes.map(_codeToSecId).join(',');
      const url = 'https://push2.eastmoney.com/api/qt/ulist.np/get';
      
      final params = {
        'ut': 'bd1d9ddb04089700cf9c27f6f7426281',
        'fltt': '2',
        'invt': '2',
        'fields': 'f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f12,f13,f14,f15,f16,f17,f18,f20,f21,f23,f24,f25,f22,f11,f62,f128,f136,f115,f152',
        'secids': secIds,
      };

      final response = await _networkManager.get(url, queryParameters: params);
      final data = response.data;

      if (data['rc'] != 0) {
        throw Exception('获取实时数据失败');
      }

      final diff = data['data']['diff'] as List<dynamic>;
      return diff.cast<Map<String, dynamic>>();

    } catch (e) {
      _logger.e('获取实时数据失败: $e');
      rethrow;
    }
  }

  /// 股票代码转换为secid格式
  String _codeToSecId(String code) {
    code = code.trim();
    if (code.startsWith('6')) {
      return '1.$code'; // 上海
    } else {
      return '0.$code'; // 深圳
    }
  }
}
