#!/bin/bash
# 快速验证所有 Make 示例

echo "========================================"
echo "测试所有 Make 示例"
echo "========================================"

cd "$(dirname "$0")/examples/make" || exit 1

for dir in */; do
    dir=${dir%/}
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试: $dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cd "$dir" || continue

    if [ -f "Makefile" ]; then
        if make > /tmp/make_test.log 2>&1; then
            echo "✓ 编译成功"
            make clean > /dev/null 2>&1
        else
            echo "✗ 编译失败"
            cat /tmp/make_test.log
        fi
    else
        echo "⚠ 没有 Makefile"
    fi

    cd ..
done

echo ""
echo "========================================"
echo "Make 示例测试完成"
echo "========================================"
