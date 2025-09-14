@echo off
echo 正在构建股票监控APK...

REM 检查Flutter是否安装
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: Flutter未安装或未添加到PATH
    echo 请先安装Flutter SDK: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Flutter环境检查通过

REM 清理项目
echo 清理项目...
flutter clean

REM 获取依赖
echo 获取依赖...
flutter pub get

REM 构建APK
echo 构建APK...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK构建成功!
    echo 📁 APK文件位置: build\app\outputs\flutter-apk\app-release.apk
    echo.
    
    REM 显示文件大小
    for %%I in (build\app\outputs\flutter-apk\app-release.apk) do (
        echo 📊 文件大小: %%~zI 字节
    )
    
    echo.
    echo 🚀 您可以将APK文件安装到Android设备上进行测试
    
    REM 询问是否打开文件夹
    set /p choice="是否打开APK文件夹? (y/N): "
    if /i "%choice%"=="y" (
        explorer build\app\outputs\flutter-apk\
    )
) else (
    echo.
    echo ❌ APK构建失败
    echo 请检查错误信息并重试
)

pause
