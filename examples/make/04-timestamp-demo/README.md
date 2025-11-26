# 示例 04: 时间戳演示

演示 Make 如何使用文件时间戳来决定是否重新编译。

## 实验步骤

```bash
# 第一次编译
make

# 不修改任何文件，再次执行
make
# 输出: make: 'program' is up to date.

# 只修改 utils.c
echo "// comment" >> utils.c
make
# 观察：只有 utils.o 和 program 被重新生成

# 修改 utils.h
echo "// comment" >> utils.h
make
# 观察：main.o 和 utils.o 都被重新编译

# 查看文件时间戳
ls -lt
stat utils.o

# 手动修改时间戳
touch -t 202301010000 utils.o
make
# 观察：utils.o 会被重新编译
```

## 调试命令

```bash
make -n    # 只显示命令，不执行
make -d    # 显示详细调试信息
```
