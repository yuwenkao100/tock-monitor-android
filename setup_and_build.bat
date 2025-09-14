@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    股票监控 APK 构建助手
echo ========================================
echo.

REM 检查Flutter是否安装
echo [1/5] 检查Flutter环境...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter未安装
    echo.
    echo 📥 请按以下步骤安装Flutter:
    echo 1. 访问: https://docs.flutter.dev/get-started/install/windows
    echo 2. 下载Flutter SDK
    echo 3. 解压到 C:\flutter
    echo 4. 添加 C:\flutter\bin 到系统PATH
    echo 5. 重启命令提示符后重新运行此脚本
    echo.
    pause
    exit /b 1
)
echo ✅ Flutter已安装

REM 检查Android工具链
echo [2/5] 检查Android环境...
flutter doctor --android-licenses >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Android许可证未接受
    echo 正在尝试接受许可证...
    flutter doctor --android-licenses
)

REM 显示环境状态
echo [3/5] 检查完整环境状态...
flutter doctor

echo.
echo 📋 环境检查完成。如果上面显示有❌错误，请先解决后再继续。
set /p continue="是否继续构建APK? (y/N): "
if /i not "%continue%"=="y" (
    echo 构建已取消
    pause
    exit /b 0
)

echo.
echo [4/5] 准备项目...

REM 检查是否在正确目录
if not exist "pubspec.yaml" (
    echo ❌ 错误: 未找到pubspec.yaml文件
    echo 请确保在android_stock_monitor目录中运行此脚本
    pause
    exit /b 1
)

REM 清理项目
echo 清理项目...
flutter clean

REM 获取依赖
echo 获取依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 依赖获取失败
    pause
    exit /b 1
)

echo [5/5] 构建APK...
echo 这可能需要几分钟时间，请耐心等待...
echo.

REM 构建APK
flutter build apk --release --verbose

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo           🎉 构建成功!
    echo ========================================
    echo.
    echo 📁 APK文件位置:
    echo    build\app\outputs\flutter-apk\app-release.apk
    echo.
    
    REM 检查文件是否存在并显示大小
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        for %%I in (build\app\outputs\flutter-apk\app-release.apk) do (
            set /a size_mb=%%~zI/1024/1024
            echo 📊 文件大小: !size_mb! MB
        )
        echo.
        echo 📱 安装方法:
        echo 1. 将APK文件传输到Android设备
        echo 2. 在设备上启用"未知来源"安装
        echo 3. 点击APK文件进行安装
        echo.
        echo 或者使用ADB安装:
        echo    adb install build\app\outputs\flutter-apk\app-release.apk
        echo.
        
        set /p open_folder="是否打开APK文件夹? (y/N): "
        if /i "!open_folder!"=="y" (
            explorer build\app\outputs\flutter-apk\
        )
    ) else (
        echo ⚠️  APK文件未找到，可能构建过程中出现问题
    )
) else (
    echo.
    echo ========================================
    echo           ❌ 构建失败
    echo ========================================
    echo.
    echo 🔧 故障排除建议:
    echo 1. 检查网络连接
    echo 2. 运行: flutter doctor -v
    echo 3. 运行: flutter clean ^&^& flutter pub get
    echo 4. 确保Android SDK已正确安装
    echo.
    echo 如需帮助，请查看 QUICK_START.md 文件
)

echo.
pause
