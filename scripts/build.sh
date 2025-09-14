#!/bin/bash

# 股票监控安卓应用构建脚本
# 使用方法: ./scripts/build.sh [debug|release|profile]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${2}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_info() {
    print_message "$1" "$BLUE"
}

print_success() {
    print_message "$1" "$GREEN"
}

print_warning() {
    print_message "$1" "$YELLOW"
}

print_error() {
    print_message "$1" "$RED"
}

# 检查Flutter环境
check_flutter() {
    print_info "检查Flutter环境..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter未安装或未添加到PATH"
        exit 1
    fi
    
    flutter --version
    flutter doctor --android-licenses
}

# 清理项目
clean_project() {
    print_info "清理项目..."
    flutter clean
    cd android && ./gradlew clean && cd ..
    print_success "项目清理完成"
}

# 获取依赖
get_dependencies() {
    print_info "获取依赖..."
    flutter pub get
    print_success "依赖获取完成"
}

# 生成代码
generate_code() {
    print_info "生成代码..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_success "代码生成完成"
}

# 运行测试
run_tests() {
    print_info "运行测试..."
    flutter test
    print_success "测试通过"
}

# 构建APK
build_apk() {
    local build_mode=$1
    print_info "构建${build_mode}版本APK..."
    
    case $build_mode in
        "debug")
            flutter build apk --debug
            ;;
        "release")
            flutter build apk --release --split-per-abi
            ;;
        "profile")
            flutter build apk --profile
            ;;
        *)
            print_error "未知的构建模式: $build_mode"
            exit 1
            ;;
    esac
    
    print_success "${build_mode}版本APK构建完成"
}

# 构建App Bundle (用于Google Play)
build_bundle() {
    print_info "构建App Bundle..."
    flutter build appbundle --release
    print_success "App Bundle构建完成"
}

# 显示构建结果
show_build_results() {
    local build_mode=$1
    print_info "构建结果:"
    
    if [ "$build_mode" = "release" ]; then
        echo "APK文件位置:"
        find build/app/outputs/flutter-apk/ -name "*.apk" -type f | while read file; do
            size=$(du -h "$file" | cut -f1)
            echo "  - $file ($size)"
        done
        
        if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
            size=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
            echo "  - build/app/outputs/bundle/release/app-release.aab ($size)"
        fi
    else
        apk_path="build/app/outputs/flutter-apk/app-${build_mode}.apk"
        if [ -f "$apk_path" ]; then
            size=$(du -h "$apk_path" | cut -f1)
            echo "  - $apk_path ($size)"
        fi
    fi
}

# 安装APK到设备
install_apk() {
    local build_mode=$1
    print_info "安装APK到设备..."
    
    # 检查是否有连接的设备
    if ! adb devices | grep -q "device$"; then
        print_warning "没有检测到连接的Android设备"
        return
    fi
    
    local apk_path
    if [ "$build_mode" = "release" ]; then
        # 选择universal APK
        apk_path="build/app/outputs/flutter-apk/app-release.apk"
    else
        apk_path="build/app/outputs/flutter-apk/app-${build_mode}.apk"
    fi
    
    if [ -f "$apk_path" ]; then
        adb install -r "$apk_path"
        print_success "APK安装完成"
    else
        print_error "APK文件不存在: $apk_path"
    fi
}

# 主函数
main() {
    local build_mode=${1:-"debug"}
    local skip_tests=${2:-"false"}
    
    print_info "开始构建股票监控应用 (模式: $build_mode)"
    
    # 检查环境
    check_flutter
    
    # 清理和准备
    clean_project
    get_dependencies
    generate_code
    
    # 运行测试（可选）
    if [ "$skip_tests" != "true" ]; then
        run_tests
    fi
    
    # 构建APK
    build_apk "$build_mode"
    
    # 如果是release模式，也构建App Bundle
    if [ "$build_mode" = "release" ]; then
        build_bundle
    fi
    
    # 显示结果
    show_build_results "$build_mode"
    
    # 询问是否安装
    read -p "是否安装到连接的设备? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_apk "$build_mode"
    fi
    
    print_success "构建完成!"
}

# 显示帮助信息
show_help() {
    echo "股票监控应用构建脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [build_mode] [skip_tests]"
    echo ""
    echo "参数:"
    echo "  build_mode   构建模式 (debug|release|profile)，默认: debug"
    echo "  skip_tests   跳过测试 (true|false)，默认: false"
    echo ""
    echo "示例:"
    echo "  $0 debug           # 构建debug版本并运行测试"
    echo "  $0 release true    # 构建release版本并跳过测试"
    echo "  $0 profile         # 构建profile版本并运行测试"
    echo ""
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
}

# 处理命令行参数
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
