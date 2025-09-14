import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// 网络请求管理器
/// 处理移动端网络环境的特殊情况，如网络切换、超时重试等
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  late Dio _dio;
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  
  bool _isInitialized = false;
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;

  /// 初始化网络管理器
  Future<void> init() async {
    if (_isInitialized) return;

    _dio = Dio();
    
    // 基础配置
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );

    // 添加拦截器
    _setupInterceptors();
    
    // 监听网络状态变化
    _setupConnectivityListener();
    
    // 获取当前网络状态
    _currentConnectivity = await _connectivity.checkConnectivity();
    
    _isInitialized = true;
    _logger.i('NetworkManager initialized');
  }

  /// 设置拦截器
  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('Request: ${options.method} ${options.uri}');
        
        // 根据网络类型调整超时时间
        if (_currentConnectivity == ConnectivityResult.mobile) {
          options.connectTimeout = const Duration(seconds: 20);
          options.receiveTimeout = const Duration(seconds: 40);
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('Request error: ${error.message}');
        handler.next(error);
      },
    ));

    // 重试拦截器
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: (message) => _logger.w(message),
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
  }

  /// 设置网络连接监听
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _currentConnectivity = result;
      _logger.i('Network connectivity changed to: $result');
      
      // 根据网络状态调整请求策略
      _adjustNetworkStrategy(result);
    });
  }

  /// 根据网络状态调整策略
  void _adjustNetworkStrategy(ConnectivityResult connectivity) {
    switch (connectivity) {
      case ConnectivityResult.wifi:
        // WiFi环境：使用较短超时时间，允许更多并发请求
        _dio.options.connectTimeout = const Duration(seconds: 10);
        _dio.options.receiveTimeout = const Duration(seconds: 20);
        break;
      case ConnectivityResult.mobile:
        // 移动网络：使用较长超时时间，减少并发请求
        _dio.options.connectTimeout = const Duration(seconds: 20);
        _dio.options.receiveTimeout = const Duration(seconds: 40);
        break;
      case ConnectivityResult.none:
        // 无网络连接
        _logger.w('No network connection available');
        break;
      default:
        break;
    }
  }

  /// 检查网络连接状态
  Future<bool> isConnected() async {
    final connectivity = await _connectivity.checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  /// 执行GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await isConnected()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No network connection',
        type: DioExceptionType.connectionError,
      );
    }

    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 执行POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await isConnected()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No network connection',
        type: DioExceptionType.connectionError,
      );
    }

    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 获取当前网络类型
  ConnectivityResult get currentConnectivity => _currentConnectivity;

  /// 是否为WiFi连接
  bool get isWiFi => _currentConnectivity == ConnectivityResult.wifi;

  /// 是否为移动网络
  bool get isMobile => _currentConnectivity == ConnectivityResult.mobile;
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger = Logger();
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] ?? 0;

    if (retryCount < retries && _shouldRetry(err)) {
      extra['retry_count'] = retryCount + 1;
      
      final delay = retryDelays.length > retryCount 
          ? retryDelays[retryCount] 
          : retryDelays.last;
      
      logPrint?.call('Retrying request (${retryCount + 1}/$retries) after ${delay.inSeconds}s: ${err.requestOptions.uri}');
      
      await Future.delayed(delay);
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 继续重试或返回错误
      }
    }

    handler.next(err);
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // 5xx服务器错误可以重试
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }
}

/// 网络异常处理工具
class NetworkErrorHandler {
  static String getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络设置';
      case DioExceptionType.sendTimeout:
        return '请求超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '请求参数错误';
          case 401:
            return '未授权访问';
          case 403:
            return '访问被禁止';
          case 404:
            return '请求的资源不存在';
          case 500:
            return '服务器内部错误';
          case 502:
            return '网关错误';
          case 503:
            return '服务暂时不可用';
          default:
            return '网络请求失败 (${statusCode ?? 'Unknown'})';
        }
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return '网络连接失败，请检查网络设置';
        }
        return '未知网络错误: ${error.message}';
    }
  }

  static bool isNetworkError(DioException error) {
    return [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ].contains(error.type);
  }
}
