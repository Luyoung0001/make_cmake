# 示例 01: Hello World

最简单的 CMake 项目。

## 构建步骤

```bash
mkdir build && cd build
cmake ..
make
./hello
```

## 清理

```bash
cd .. && rm -rf build
```

## CMake 命令选项

```bash
# 指定构建类型
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake -DCMAKE_BUILD_TYPE=Release ..

# 查看配置
cmake -L ..
cmake -LH ..

# 详细输出
make VERBOSE=1
```
