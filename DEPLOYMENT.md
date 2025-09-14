# 股票监控应用部署指南

## 构建环境要求

### 系统要求
- **操作系统**: Windows 10/11, macOS 10.14+, 或 Ubuntu 18.04+
- **内存**: 至少 8GB RAM (推荐 16GB)
- **存储**: 至少 10GB 可用空间
- **网络**: 稳定的互联网连接

### 开发工具
- **Flutter SDK**: 3.0.0 或更高版本
- **Dart SDK**: 2.17.0 或更高版本
- **Android Studio**: 2022.1 或更高版本
- **Android SDK**: API Level 21-34
- **Java**: JDK 8 或更高版本

## 构建步骤

### 1. 环境准备

```bash
# 检查Flutter环境
flutter doctor

# 接受Android许可证
flutter doctor --android-licenses

# 检查连接的设备
flutter devices
```

### 2. 项目配置

```bash
# 克隆项目
git clone <repository-url>
cd android_stock_monitor

# 安装依赖
flutter pub get

# 生成代码
flutter packages pub run build_runner build
```

### 3. 签名配置

#### Debug签名（开发用）
Debug版本使用默认的debug.keystore，无需额外配置。

#### Release签名（生产用）
1. 生成签名密钥：
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. 创建 `android/key.properties` 文件：
```properties
storePassword=<密码>
keyPassword=<密钥密码>
keyAlias=upload
storeFile=<密钥文件路径>
```

3. 在 `android/app/build.gradle` 中配置签名。

### 4. 构建应用

#### 使用构建脚本（推荐）
```bash
# 给脚本执行权限
chmod +x scripts/build.sh

# 构建debug版本
./scripts/build.sh debug

# 构建release版本
./scripts/build.sh release

# 构建profile版本
./scripts/build.sh profile
```

#### 手动构建
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release --split-per-abi

# App Bundle (Google Play)
flutter build appbundle --release
```

## 测试

### 单元测试
```bash
flutter test
```

### 集成测试
```bash
flutter test integration_test/
```

### 设备测试
```bash
# 安装到连接的设备
flutter install

# 运行应用
flutter run --release
```

## 发布准备

### 应用商店资料

#### 应用信息
- **应用名称**: 股票监控
- **包名**: com.stockmonitor.app
- **版本号**: 1.0.0
- **最低Android版本**: Android 5.0 (API 21)
- **目标Android版本**: Android 14 (API 34)

#### 应用描述
```
股票监控是一款专业的股票技术分析工具，帮助投资者识别股票交易信号。

主要功能：
• 实时股票数据监控
• 阴背量技术分析
• 压力带突破信号
• 自定义参数配置
• 后台监控提醒
• 深色/浅色主题

适用人群：
• 股票投资者
• 技术分析爱好者
• 量化交易研究者

注意：本应用仅提供技术分析参考，不构成投资建议。
```

#### 应用截图
需要准备以下尺寸的截图：
- 手机截图: 1080x1920 (至少2张，最多8张)
- 平板截图: 1200x1920 (可选)
- 应用图标: 512x512

#### 隐私政策
创建隐私政策页面，说明：
- 数据收集范围
- 数据使用目的
- 数据存储方式
- 用户权利

### Google Play Console

1. **创建应用**
   - 登录 Google Play Console
   - 创建新应用
   - 填写应用信息

2. **上传App Bundle**
   ```bash
   # 构建App Bundle
   flutter build appbundle --release
   
   # 文件位置: build/app/outputs/bundle/release/app-release.aab
   ```

3. **配置发布**
   - 设置内容分级
   - 配置定价和分发
   - 添加应用截图和描述

4. **测试发布**
   - 创建内部测试轨道
   - 邀请测试用户
   - 收集反馈

### 其他应用商店

#### 华为应用市场
- 注册华为开发者账号
- 上传APK文件
- 填写应用信息
- 等待审核

#### 小米应用商店
- 注册小米开发者账号
- 上传APK文件
- 提供应用资质
- 等待审核

## 版本管理

### 版本号规则
使用语义化版本号：`主版本.次版本.修订版本`

- **主版本**: 不兼容的API修改
- **次版本**: 向下兼容的功能性新增
- **修订版本**: 向下兼容的问题修正

### 发布流程
1. 更新版本号 (`pubspec.yaml`)
2. 更新变更日志 (`CHANGELOG.md`)
3. 创建Git标签
4. 构建发布版本
5. 上传到应用商店
6. 发布公告

## 监控和维护

### 崩溃监控
集成Firebase Crashlytics或其他崩溃监控工具。

### 性能监控
- 应用启动时间
- 内存使用情况
- 网络请求性能
- 电池消耗

### 用户反馈
- 应用商店评论
- 应用内反馈功能
- 用户支持邮箱

## 故障排除

### 常见问题

1. **构建失败**
   - 检查Flutter和Android SDK版本
   - 清理项目: `flutter clean`
   - 重新获取依赖: `flutter pub get`

2. **签名错误**
   - 检查签名配置
   - 验证密钥文件路径
   - 确认密码正确

3. **权限问题**
   - 检查AndroidManifest.xml
   - 确认目标SDK版本
   - 测试权限申请流程

4. **网络请求失败**
   - 检查网络权限
   - 验证API接口
   - 测试网络连接

### 调试工具
- Flutter Inspector
- Android Studio Profiler
- ADB日志: `adb logcat`
- 网络抓包工具

## 安全考虑

### 代码保护
- 启用代码混淆
- 移除调试信息
- 保护API密钥

### 数据安全
- 加密敏感数据
- 使用HTTPS通信
- 验证服务器证书

### 权限最小化
- 只申请必要权限
- 运行时权限检查
- 权限使用说明

## 联系信息

- **开发者**: [开发者名称]
- **邮箱**: [support@example.com]
- **网站**: [https://example.com]
- **技术支持**: [技术支持联系方式]
