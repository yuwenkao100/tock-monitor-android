@echo off
title 股票监控 - 一键APK打包工具
color 0A

echo.
echo     ╔══════════════════════════════════════╗
echo     ║        股票监控 APK 打包工具         ║
echo     ║            超简单版本                ║
echo     ╚══════════════════════════════════════╝
echo.

REM 检查是否在正确目录
if not exist "pubspec.yaml" (
    echo ❌ 错误：请在 android_stock_monitor 目录中运行此工具
    echo.
    echo 📁 当前目录：%CD%
    echo 📁 应该在：android_stock_monitor 文件夹内
    echo.
    pause
    exit /b 1
)

echo 🔍 检测到Flutter项目：股票监控
echo.

REM 选择构建方式
echo 请选择APK构建方式：
echo.
echo [1] 🌐 在线构建（推荐，无需安装任何软件）
echo [2] 🔧 本地构建（需要Flutter环境）
echo [3] 📦 使用便携版Flutter（自动下载）
echo [4] ❓ 查看详细说明
echo.

set /p choice="请输入选择 (1-4): "

if "%choice%"=="1" goto online_build
if "%choice%"=="2" goto local_build
if "%choice%"=="3" goto portable_build
if "%choice%"=="4" goto show_help
goto invalid_choice

:online_build
echo.
echo 🌐 在线构建方案
echo ================
echo.
echo 📋 步骤：
echo 1. 将项目上传到GitHub
echo 2. 使用Codemagic在线构建
echo 3. 下载生成的APK
echo.
echo 🔗 推荐服务：
echo • Codemagic: https://codemagic.io
echo • GitHub Actions: https://github.com/features/actions
echo • AppCenter: https://appcenter.ms
echo.
echo 💡 优点：
echo • 无需安装任何软件
echo • 构建环境已优化
echo • 支持自动化
echo.
echo 📖 详细教程即将为您生成...
goto create_online_guide

:local_build
echo.
echo 🔧 本地构建方案
echo ================
echo.
echo 正在检查Flutter环境...

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter未安装
    echo.
    echo 📥 请选择：
    echo [A] 安装完整Flutter环境
    echo [B] 使用便携版Flutter（选项3）
    echo [C] 使用在线构建（选项1）
    echo.
    set /p sub_choice="请选择 (A/B/C): "
    if /i "%sub_choice%"=="A" goto install_flutter
    if /i "%sub_choice%"=="B" goto portable_build
    if /i "%sub_choice%"=="C" goto online_build
    goto local_build
)

echo ✅ Flutter环境检测通过
echo.
echo 🚀 开始构建APK...
echo.

call flutter clean
call flutter pub get
call flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK构建成功！
    echo 📁 文件位置：build\app\outputs\flutter-apk\app-release.apk
    echo.
    explorer build\app\outputs\flutter-apk\
) else (
    echo ❌ 构建失败，请检查错误信息
)
goto end

:portable_build
echo.
echo 📦 便携版Flutter方案
echo ====================
echo.
echo ⚠️  此功能需要下载约600MB的Flutter SDK
echo 📁 将下载到临时目录，不影响系统
echo.
set /p confirm="是否继续？(y/N): "
if /i not "%confirm%"=="y" goto main_menu

echo.
echo 🔄 准备便携版Flutter环境...
echo （此功能正在开发中，请选择其他方案）
echo.
pause
goto main_menu

:show_help
echo.
echo ❓ 详细说明
echo ============
echo.
echo 🎯 各方案对比：
echo.
echo 方案1 - 在线构建：
echo   ✅ 最简单，无需安装软件
echo   ✅ 构建环境稳定
echo   ❌ 需要上传代码到云端
echo   ❌ 需要网络连接
echo.
echo 方案2 - 本地构建：
echo   ✅ 代码保密性好
echo   ✅ 构建速度快
echo   ❌ 需要安装Flutter环境（约1GB）
echo   ❌ 配置相对复杂
echo.
echo 方案3 - 便携版：
echo   ✅ 无需系统安装
echo   ✅ 一次下载，多次使用
echo   ❌ 首次下载较大
echo   🚧 功能开发中
echo.
pause
goto main_menu

:create_online_guide
echo.
echo 📝 正在生成在线构建教程...

(
echo # 🌐 在线APK构建详细教程
echo.
echo ## 方法一：使用Codemagic ^(推荐^)
echo.
echo ### 步骤1：准备代码
echo 1. 将 android_stock_monitor 文件夹上传到GitHub
echo 2. 创建新的GitHub仓库
echo 3. 上传所有项目文件
echo.
echo ### 步骤2：配置Codemagic
echo 1. 访问：https://codemagic.io
echo 2. 使用GitHub账号登录
echo 3. 点击 "Add application"
echo 4. 选择您的GitHub仓库
echo 5. 选择 "Flutter App"
echo.
echo ### 步骤3：开始构建
echo 1. 点击 "Start new build"
echo 2. 选择 "Release" 模式
echo 3. 等待构建完成 ^(约10-15分钟^)
echo 4. 下载生成的APK文件
echo.
echo ## 方法二：使用GitHub Actions
echo.
echo ### 创建构建配置文件
echo 在项目根目录创建：.github/workflows/build.yml
echo.
echo ```yaml
echo name: Build APK
echo on: [push]
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo     - uses: actions/checkout@v2
echo     - uses: subosito/flutter-action@v2
echo     - run: flutter pub get
echo     - run: flutter build apk --release
echo     - uses: actions/upload-artifact@v2
echo       with:
echo         name: apk
echo         path: build/app/outputs/flutter-apk/app-release.apk
echo ```
echo.
echo ### 使用步骤
echo 1. 将代码推送到GitHub
echo 2. GitHub自动开始构建
echo 3. 在Actions页面下载APK
echo.
echo ## 💡 推荐方案
echo.
echo 对于初次使用者，推荐使用 **Codemagic**：
echo - 界面友好，操作简单
echo - 免费额度充足
echo - 构建速度快
echo - 支持多种配置
echo.
echo ## 📞 需要帮助？
echo.
echo 如果在使用过程中遇到问题：
echo 1. 检查项目文件是否完整上传
echo 2. 确认pubspec.yaml文件格式正确
echo 3. 查看构建日志中的错误信息
) > "在线构建教程.md"

echo ✅ 教程已生成：在线构建教程.md
echo.
notepad "在线构建教程.md"
goto end

:install_flutter
echo.
echo 📥 Flutter安装指南
echo ==================
echo.
echo 请访问：https://docs.flutter.dev/get-started/install/windows
echo 或运行：install_flutter_minimal.bat
echo.
pause
goto end

:invalid_choice
echo.
echo ❌ 无效选择，请重新输入
echo.
pause

:main_menu
cls
goto :start

:end
echo.
echo 🎉 感谢使用股票监控APK打包工具！
echo.
pause

:start
goto :eof
