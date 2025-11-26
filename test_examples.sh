#!/bin/bash

# Make 和 CMake 教程示例测试脚本

set -e  # 遇到错误立即退出

echo "========================================"
echo "Make & CMake 教程示例测试"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数器
TOTAL=0
PASSED=0
FAILED=0

# 测试函数
test_example() {
    local name=$1
    local dir=$2
    local build_cmd=$3
    local test_cmd=$4

    TOTAL=$((TOTAL + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试: $name"
    echo "目录: $dir"
    echo ""

    if [ ! -d "$dir" ]; then
        echo -e "${RED}✗ 失败: 目录不存在${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi

    cd "$dir"

    echo "构建命令: $build_cmd"
    if eval "$build_cmd" > /tmp/test_build.log 2>&1; then
        echo -e "${GREEN}✓ 构建成功${NC}"

        if [ -n "$test_cmd" ]; then
            echo "测试命令: $test_cmd"
            if eval "$test_cmd" > /tmp/test_run.log 2>&1; then
                echo -e "${GREEN}✓ 运行成功${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ 运行失败${NC}"
                cat /tmp/test_run.log
                FAILED=$((FAILED + 1))
            fi
        else
            PASSED=$((PASSED + 1))
        fi
    else
        echo -e "${RED}✗ 构建失败${NC}"
        cat /tmp/test_build.log
        FAILED=$((FAILED + 1))
    fi

    # 清理
    if [ -f "Makefile" ]; then
        make clean > /dev/null 2>&1 || true
    fi
    rm -rf build > /dev/null 2>&1 || true

    cd - > /dev/null
    echo ""
}

# 检查环境
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_tool() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓ $1: $($1 --version | head -n 1)${NC}"
        return 0
    else
        echo -e "${RED}✗ $1: 未安装${NC}"
        return 1
    fi
}

ENV_OK=true
check_tool gcc || ENV_OK=false
check_tool make || ENV_OK=false
check_tool cmake || ENV_OK=false

if [ "$ENV_OK" = false ]; then
    echo ""
    echo -e "${YELLOW}警告: 缺少必要工具，请先安装：${NC}"
    echo "  sudo apt install build-essential cmake"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试 Make 示例"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 进入 examples 目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/examples"

if [ ! -d "$EXAMPLES_DIR" ]; then
    echo -e "${RED}错误: examples 目录不存在${NC}"
    exit 1
fi

# Make 示例测试
test_example \
    "Make 01: Hello World" \
    "$EXAMPLES_DIR/make/01-hello-world" \
    "make" \
    "./hello"

test_example \
    "Make 02: 变量" \
    "$EXAMPLES_DIR/make/02-variables" \
    "make" \
    "./main"

test_example \
    "Make 03: 单文件" \
    "$EXAMPLES_DIR/make/03-single-file" \
    "make" \
    "./calculator"

test_example \
    "Make 04: 时间戳" \
    "$EXAMPLES_DIR/make/04-timestamp-demo" \
    "make" \
    "./program"

test_example \
    "Make 05: 模式规则" \
    "$EXAMPLES_DIR/make/05-pattern-rules" \
    "make" \
    "./app"

test_example \
    "Make 06: 批量编译" \
    "$EXAMPLES_DIR/make/06-batch-compile" \
    "make" \
    "./build/calculator"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试 CMake 示例"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# CMake 示例测试
test_example \
    "CMake 01: Hello World" \
    "$EXAMPLES_DIR/cmake/01-hello-world" \
    "mkdir -p build && cd build && cmake .. && make" \
    "./build/hello"

test_example \
    "CMake 02: 库" \
    "$EXAMPLES_DIR/cmake/02-library" \
    "mkdir -p build && cd build && cmake .. && make" \
    "./build/mathapp"

# 测试总结
echo "========================================"
echo "测试总结"
echo "========================================"
echo -e "总计: $TOTAL"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}✗ 有 $FAILED 个测试失败${NC}"
    exit 1
fi
