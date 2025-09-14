#!/bin/bash

# 股票监控APK构建脚本 (Linux/macOS)

set -e

echo "🚀 正在构建股票监控APK..."

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter未安装或未添加到PATH"
    echo "请先安装Flutter SDK: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter环境检查通过"

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 构建APK
echo "🔨 构建APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK构建成功!"
    echo "📁 APK文件位置: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    
    # 显示文件大小
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        size=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "📊 文件大小: $size"
    fi
    
    echo ""
    echo "🚀 您可以将APK文件安装到Android设备上进行测试"
    echo ""
    
    # 询问是否打开文件夹
    read -p "是否打开APK文件夹? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v open &> /dev/null; then
            open build/app/outputs/flutter-apk/
        elif command -v xdg-open &> /dev/null; then
            xdg-open build/app/outputs/flutter-apk/
        else
            echo "请手动打开文件夹: build/app/outputs/flutter-apk/"
        fi
    fi
else
    echo ""
    echo "❌ APK构建失败"
    echo "请检查错误信息并重试"
    exit 1
fi
