#!/bin/bash
# 快速验证所有 CMake 示例

echo "========================================"
echo "测试所有 CMake 示例"
echo "========================================"

cd "$(dirname "$0")/examples/cmake" || exit 1

for dir in */; do
    dir=${dir%/}
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试: $dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cd "$dir" || continue

    if [ -f "CMakeLists.txt" ]; then
        # 清理旧的 build 目录
        rm -rf build
        mkdir -p build
        cd build

        # 配置
        if cmake .. > /tmp/cmake_config.log 2>&1; then
            echo "✓ 配置成功"

            # 编译
            if make > /tmp/cmake_build.log 2>&1; then
                echo "✓ 编译成功"
            else
                echo "✗ 编译失败"
                cat /tmp/cmake_build.log | head -20
            fi
        else
            echo "✗ 配置失败"
            cat /tmp/cmake_config.log | tail -10
        fi

        cd ..
        rm -rf build
    else
        echo "⚠ 没有 CMakeLists.txt"
    fi

    cd ..
done

echo ""
echo "========================================"
echo "CMake 示例测试完成"
echo "========================================"
