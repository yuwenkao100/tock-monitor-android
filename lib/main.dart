import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'services/api_service.dart';
import 'services/database_service.dart';
import 'services/network_manager.dart';
import 'screens/home_screen.dart';
import 'utils/themes.dart';
import 'providers/stock_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化服务
  await _initializeServices();

  runApp(const StockMonitorApp());
}

/// 初始化应用服务
Future<void> _initializeServices() async {
  try {
    // 初始化网络管理器
    await NetworkManager().init();
    
    // 初始化API服务
    await EastmoneyApiService().init();
    
    // 初始化数据库（会在首次访问时自动初始化）
    await DatabaseService().database;
    
    print('All services initialized successfully');
  } catch (e) {
    print('Failed to initialize services: $e');
  }
}

class StockMonitorApp extends StatelessWidget {
  const StockMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: '股票监控',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: settingsProvider.themeMode,
            home: const HomeScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // 固定字体缩放比例
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}


