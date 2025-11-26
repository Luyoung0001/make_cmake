# 示例 01: Hello World

这是最简单的 Makefile 示例。

## 编译运行

```bash
make        # 编译
./hello     # 运行
make clean  # 清理
```

## 关键点

1. Makefile 中的命令必须以 Tab 键开头
2. `hello` 是目标，`hello.c` 是依赖
3. `.PHONY` 声明 `clean` 是伪目标，不是真实文件
