#!/bin/bash
# 任务规划表编译脚本

echo "==================================="
echo "  任务规划表 - 编译脚本"
echo "==================================="

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter SDK"
    echo "   访问: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter版本:"
flutter --version | head -1

# 获取依赖
echo ""
echo "📦 正在获取依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖获取失败"
    exit 1
fi

# 编译APK
echo ""
echo "🔨 正在编译APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 编译成功！"
    echo ""
    echo "📱 APK文件位置:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📲 安装方法:"
    echo "   1. 将APK传输到手机"
    echo "   2. 点击安装"
    echo "   3. 如提示未知来源，请在设置中允许"
else
    echo "❌ 编译失败，请检查错误信息"
    exit 1
fi
