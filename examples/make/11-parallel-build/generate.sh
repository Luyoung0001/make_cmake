#!/bin/bash
# 生成测试文件
mkdir -p src
for i in {1..20}; do
    echo "int func$i() { return $i; }" > src/file$i.c
done
echo "int main() { return 0; }" > src/main.c
echo "Generated 21 source files"
