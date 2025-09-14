# 🚀 股票监控APK快速构建指南

## 📋 前置要求

### 1. 安装Flutter SDK

#### Windows系统:
1. 下载Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. 解压到 `C:\flutter` 目录
3. 添加 `C:\flutter\bin` 到系统PATH环境变量
4. 重启命令提示符

#### 验证安装:
```cmd
flutter --version
flutter doctor
```

### 2. 安装Android Studio
1. 下载Android Studio: https://developer.android.com/studio
2. 安装时选择包含Android SDK
3. 启动Android Studio，完成初始设置
4. 安装Android SDK (API 21-34)

### 3. 配置Android环境
```cmd
flutter doctor --android-licenses
```
输入 `y` 接受所有许可证

## 🔨 构建APK

### 方法一: 使用构建脚本 (推荐)

#### Windows:
```cmd
cd android_stock_monitor
build_apk.bat
```

#### Linux/macOS:
```bash
cd android_stock_monitor
chmod +x build_apk.sh
./build_apk.sh
```

### 方法二: 手动构建

```cmd
cd android_stock_monitor

# 清理项目
flutter clean

# 获取依赖
flutter pub get

# 构建APK
flutter build apk --release
```

## 📁 输出文件

构建成功后，APK文件位于:
```
android_stock_monitor/build/app/outputs/flutter-apk/app-release.apk
```

## 📱 安装APK

### 方法一: 通过ADB安装
```cmd
# 连接Android设备，启用USB调试
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 方法二: 直接安装
1. 将APK文件传输到Android设备
2. 在设备上启用"未知来源"安装
3. 点击APK文件进行安装

## 🛠️ 故障排除

### 常见问题

#### 1. Flutter命令不识别
- 确认Flutter已添加到PATH环境变量
- 重启命令提示符/终端

#### 2. Android许可证未接受
```cmd
flutter doctor --android-licenses
```

#### 3. 构建失败
```cmd
flutter clean
flutter pub get
flutter doctor -v
```

#### 4. 设备连接问题
```cmd
adb devices
```

### 环境检查
运行以下命令检查环境:
```cmd
flutter doctor -v
```

确保显示:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Android Studio

## 📊 APK信息

- **应用名称**: 股票监控
- **包名**: com.stockmonitor.app
- **版本**: 1.0.0
- **最小Android版本**: 5.0 (API 21)
- **目标Android版本**: 14 (API 34)
- **预计大小**: 15-25 MB

## 🎯 功能特性

✅ **已实现功能**:
- 股票数据获取 (东方财富API)
- 阴背量技术分析算法
- 移动平均线计算
- SQLite数据存储
- Material Design界面
- 深色/浅色主题
- 后台监控服务
- 本地推送通知

🚧 **开发中功能**:
- 实时图表显示
- 更多技术指标
- 自选股管理
- 价格预警

## 📞 技术支持

如果在构建过程中遇到问题:

1. **检查环境**: 运行 `flutter doctor -v`
2. **清理重试**: 运行 `flutter clean && flutter pub get`
3. **查看日志**: 构建时的详细错误信息
4. **更新工具**: 确保Flutter和Android Studio是最新版本

## 🔄 更新应用

要更新应用版本:

1. 修改 `pubspec.yaml` 中的版本号
2. 重新构建APK
3. 卸载旧版本后安装新版本

## 📝 开发说明

这是从Python桌面应用转换而来的Flutter移动应用，保持了原有的核心技术分析功能，并针对移动端进行了优化。

项目结构:
```
android_stock_monitor/
├── lib/                  # Dart源代码
├── android/             # Android平台配置
├── build/               # 构建输出目录
└── build_apk.*          # 构建脚本
```
