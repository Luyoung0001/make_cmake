# 示例 07: 条件编译

演示如何根据不同配置（Debug/Release）编译不同版本。

## 使用方法

```bash
# Debug 版本
make BUILD_TYPE=debug
# 或简写
make debug

# Release 版本
make BUILD_TYPE=release
# 或简写
make release

# 运行
./build/debug/app
./build/release/app

# 查看配置
make info

# 清理
make clean
```

## 关键点

1. 使用 `BUILD_TYPE` 变量控制编译类型
2. `ifeq` 条件判断设置不同的 `CFLAGS`
3. 不同配置生成到不同的 `build` 子目录
4. 使用 `$(error ...)` 处理无效的配置

## 输出对比

Debug 版本会输出额外的调试信息，Release 版本则只输出必要信息。
