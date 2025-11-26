# 示例 11: 并行编译

演示 make -j 并行编译的效果。

## 使用

```bash
# 生成测试文件
bash generate.sh

# 串行编译
time make

# 并行编译
make clean
time make -j4

# 使用所有 CPU
make clean
time make -j$(nproc)
```
