# 📱 股票监控安卓版 (Stock Monitor Android)

🚀 **基于Flutter开发的专业股票技术分析应用**

从Python桌面版本完整移植而来，保留所有核心分析功能，专为移动端优化设计。

## 🎯 快速开始

### 📦 直接下载APK
如果您只想使用应用，可以直接下载预构建的APK文件进行安装。

### 🔨 自己构建APK
如果您想自己构建APK文件：

#### Windows用户:
```cmd
cd android_stock_monitor
setup_and_build.bat
```

#### Linux/macOS用户:
```bash
cd android_stock_monitor
chmod +x build_apk.sh
./build_apk.sh
```

详细构建指南请查看 [QUICK_START.md](QUICK_START.md)

## 功能特性

### 核心功能
- 📈 实时股票数据获取（东方财富API）
- 🔍 技术分析算法（阴背量、压力带分析）
- 📊 可视化图表展示
- ⚙️ 参数配置管理
- 📱 移动端友好界面

### 移动端特性
- 🔔 后台监控与推送通知
- 💾 本地数据缓存（SQLite）
- 🌙 深色/浅色主题切换
- 📱 响应式布局设计
- 🔄 下拉刷新数据

## 技术架构

```
android_stock_monitor/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── stock_data.dart
│   │   ├── analysis_result.dart
│   │   └── config.dart
│   ├── services/                 # 业务服务
│   │   ├── api_service.dart      # API调用服务
│   │   ├── database_service.dart # 数据库服务
│   │   ├── analysis_service.dart # 技术分析服务
│   │   └── notification_service.dart # 通知服务
│   ├── screens/                  # 页面UI
│   │   ├── home_screen.dart
│   │   ├── watchlist_screen.dart
│   │   ├── analysis_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                  # 通用组件
│   │   ├── stock_chart.dart
│   │   ├── stock_card.dart
│   │   └── parameter_slider.dart
│   └── utils/                    # 工具类
│       ├── constants.dart
│       ├── helpers.dart
│       └── themes.dart
├── android/                      # Android平台配置
├── assets/                       # 资源文件
└── pubspec.yaml                  # 依赖配置
```

## 开发环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0
- Android Studio / VS Code
- Android SDK (API level 21+)

## 安装与运行

1. 克隆项目
```bash
git clone <repository-url>
cd android_stock_monitor
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 核心算法移植

### 阴背量分析算法
原Python算法已转换为Dart实现，保持相同的计算逻辑：
- 成交量倍数阈值检测
- 压力带百分比计算
- 成交量确认比率分析

### 技术指标计算
- 移动平均线（MA5, MA10, MA20, MA60, MA120）
- 成交量移动平均（VMA）
- 振幅计算
- 涨跌幅分析

## 数据存储

使用SQLite本地数据库存储：
- 股票基础信息
- 历史K线数据
- 分析结果缓存
- 用户配置参数

## API接口

继续使用东方财富API获取数据：
- K线数据接口
- 涨停板数据接口
- 股票基础信息接口

## 许可证

MIT License
