# 附录

## 附录 A：Linux 基础知识补充

### Shell 基本命令

在使用 Make 和 CMake 的过程中，你会经常用到这些 Shell 命令：

#### 文件操作
```bash
# 列出文件
ls -la              # 详细列表，包括隐藏文件
ls -lh              # 人类可读的文件大小
ls -lt              # 按修改时间排序

# 创建/删除目录
mkdir -p path/to/dir    # 递归创建
rmdir empty_dir         # 删除空目录
rm -rf directory        # 递归删除（危险！）

# 复制/移动
cp source dest          # 复制文件
cp -r src_dir dest_dir  # 递归复制目录
mv old new              # 移动/重命名

# 查看文件
cat file.txt            # 显示整个文件
less file.txt           # 分页查看
head -n 10 file.txt     # 前 10 行
tail -n 10 file.txt     # 后 10 行
tail -f log.txt         # 实时查看日志
```

#### 文件查找
```bash
# find - 查找文件
find . -name "*.c"                    # 查找所有 .c 文件
find . -type f -name "Makefile"       # 查找名为 Makefile 的文件
find . -type d -name "build"          # 查找名为 build 的目录
find . -mtime -7                      # 7 天内修改的文件
find . -size +1M                      # 大于 1MB 的文件

# grep - 搜索文件内容
grep "pattern" file.txt               # 搜索文本
grep -r "TODO" src/                   # 递归搜索
grep -i "error" log.txt               # 忽略大小写
grep -n "main" main.c                 # 显示行号
grep -v "comment" file.txt            # 反向匹配

# 组合使用
find . -name "*.c" -exec grep -l "main" {} \;
```

#### 权限管理
```bash
# chmod - 修改权限
chmod 755 script.sh     # rwxr-xr-x
chmod +x file           # 添加执行权限
chmod u+x,g+r file      # 用户添加执行，组添加读取

# 权限表示
# r (read)    = 4
# w (write)   = 2
# x (execute) = 1
# 755 = rwxr-xr-x = 用户(7=rwx) 组(5=r-x) 其他(5=r-x)

# chown - 修改所有者
sudo chown user:group file
sudo chown -R user:group directory

# 查看权限
ls -l file
```

### 环境变量与路径

#### 环境变量操作
```bash
# 查看环境变量
echo $PATH
echo $HOME
echo $USER

# 设置环境变量
export MY_VAR="value"
export PATH="/new/path:$PATH"

# 永久设置（添加到 ~/.bashrc 或 ~/.profile）
echo 'export MY_VAR="value"' >> ~/.bashrc
source ~/.bashrc

# 取消环境变量
unset MY_VAR

# 查看所有环境变量
env
printenv
```

#### PATH 相关
```bash
# 查看 PATH
echo $PATH | tr ':' '\n'    # 分行显示

# 添加到 PATH（临时）
export PATH="/opt/myapp/bin:$PATH"

# 查找命令位置
which cmake
whereis gcc
type -a make

# 查看库路径
echo $LD_LIBRARY_PATH
ldconfig -p | grep libname
```

### 编译器与链接器基础

#### GCC/Clang 编译过程

```bash
# 完整的编译过程
gcc -E main.c -o main.i          # 预处理
gcc -S main.i -o main.s          # 编译到汇编
gcc -c main.s -o main.o          # 汇编到目标文件
gcc main.o -o main               # 链接

# 一步完成
gcc main.c -o main

# 常用选项
gcc -c main.c                    # 只编译不链接
gcc -o output main.c             # 指定输出文件名
gcc -Wall main.c                 # 显示所有警告
gcc -Werror main.c               # 警告视为错误
gcc -g main.c                    # 包含调试信息
gcc -O2 main.c                   # 优化级别 2
gcc -std=c11 main.c              # 指定 C 标准

# 预处理器宏
gcc -DDEBUG main.c               # 定义宏 DEBUG
gcc -DVERSION='"1.0"' main.c     # 定义字符串宏

# 包含路径和库
gcc -I./include main.c           # 添加头文件搜索路径
gcc -L./lib main.c -lmylib       # 添加库搜索路径并链接库
gcc main.c -lpthread -lm         # 链接 pthread 和 math 库
```

#### 查看二进制文件信息

```bash
# file - 查看文件类型
file a.out
file libmylib.so

# ldd - 查看动态库依赖
ldd ./myapp

# nm - 查看符号表
nm myapp                         # 所有符号
nm -D libmylib.so                # 动态符号
nm -u myapp                      # 未定义符号
nm --demangle myapp              # C++ 符号解码

# readelf - 读取 ELF 信息
readelf -h myapp                 # ELF 头
readelf -S myapp                 # 节表
readelf -s myapp                 # 符号表
readelf -d myapp                 # 动态段

# objdump - 反汇编
objdump -d myapp                 # 反汇编
objdump -t myapp                 # 符号表
objdump -x myapp                 # 所有头信息

# size - 查看段大小
size myapp

# strip - 删除符号
strip myapp                      # 减小文件大小
strip -s libmylib.a              # 删除静态库中的符号
```

### 动态库与静态库

#### 创建和使用静态库

```bash
# 1. 编译目标文件
gcc -c lib1.c -o lib1.o
gcc -c lib2.c -o lib2.o

# 2. 创建静态库
ar rcs libmylib.a lib1.o lib2.o

# 3. 查看静态库内容
ar -t libmylib.a
nm libmylib.a

# 4. 使用静态库
gcc main.c -L. -lmylib -o myapp
# 或
gcc main.c libmylib.a -o myapp
```

#### 创建和使用动态库

```bash
# 1. 编译位置无关代码
gcc -fPIC -c lib1.c -o lib1.o
gcc -fPIC -c lib2.c -o lib2.o

# 2. 创建动态库
gcc -shared -o libmylib.so lib1.o lib2.o

# 或一步完成
gcc -shared -fPIC lib1.c lib2.c -o libmylib.so

# 3. 设置版本号
gcc -shared -Wl,-soname,libmylib.so.1 -o libmylib.so.1.0.0 lib1.o lib2.o
ln -s libmylib.so.1.0.0 libmylib.so.1
ln -s libmylib.so.1 libmylib.so

# 4. 使用动态库
gcc main.c -L. -lmylib -o myapp

# 5. 运行时查找库
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
./myapp

# 或使用 rpath
gcc main.c -L. -lmylib -Wl,-rpath,. -o myapp
```

#### 静态库 vs 动态库对比

| 特性 | 静态库 (.a) | 动态库 (.so) |
|------|-----------|-------------|
| **大小** | 较大（代码被复制到每个可执行文件） | 较小（代码共享） |
| **启动速度** | 快 | 稍慢（需要加载） |
| **内存使用** | 多个程序各自加载 | 多个程序共享 |
| **更新** | 需要重新编译 | 只需替换 .so 文件 |
| **分发** | 简单（无依赖） | 需要确保库可用 |
| **适用场景** | 小程序、嵌入式 | 大程序、系统库 |

#### pkg-config 工具

```bash
# 查找包
pkg-config --list-all | grep openssl

# 获取编译标志
pkg-config --cflags openssl
pkg-config --libs openssl

# 在编译中使用
gcc main.c $(pkg-config --cflags --libs openssl) -o myapp

# 在 Makefile 中使用
CFLAGS += $(shell pkg-config --cflags openssl)
LDFLAGS += $(shell pkg-config --libs openssl)

# 查看包信息
pkg-config --modversion openssl
pkg-config --variable=prefix openssl
```

---

## 附录 B：实战项目

### 项目 1：多模块 C 项目（Make）

**项目结构：**
```
calculator/
├── Makefile
├── include/
│   ├── calc.h
│   └── history.h
├── src/
│   ├── main.c
│   ├── basic_ops.c
│   ├── advanced_ops.c
│   └── history.c
└── tests/
    └── test_calc.c
```

**完整示例见：** `examples/projects/01-calculator-make/`

**特点：**
- 模块化设计
- 自动依赖生成
- 测试集成
- Debug/Release 构建
- 安装脚本

### 项目 2：跨平台 C++ 项目（CMake）

**项目结构：**
```
network-app/
├── CMakeLists.txt
├── cmake/
│   ├── FindLibEvent.cmake
│   └── CompilerWarnings.cmake
├── include/
│   └── network/
│       ├── server.h
│       └── client.h
├── src/
│   ├── CMakeLists.txt
│   ├── server.cpp
│   └── client.cpp
├── tests/
│   ├── CMakeLists.txt
│   └── test_network.cpp
└── examples/
    ├── CMakeLists.txt
    └── echo_server.cpp
```

**完整示例见：** `examples/projects/02-network-cmake/`

**特点：**
- 跨平台（Linux/Windows/macOS）
- 第三方库集成
- 单元测试（Google Test）
- 文档生成（Doxygen）
- CPack 打包

### 项目 3：混合使用 Make 和 CMake

**场景：** 在大型项目中，某些子模块使用 Make，主项目使用 CMake。

**主项目 CMakeLists.txt：**
```cmake
cmake_minimum_required(VERSION 3.15)
project(HybridProject)

# 使用 ExternalProject 集成 Make 子项目
include(ExternalProject)

ExternalProject_Add(legacy_module
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/legacy
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -C <SOURCE_DIR>
    INSTALL_COMMAND make -C <SOURCE_DIR> install PREFIX=${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
)

# CMake 子项目
add_subdirectory(modern_module)

# 主程序依赖两个模块
add_executable(main main.cpp)
add_dependencies(main legacy_module)
target_link_libraries(main PRIVATE modern_module)
```

---

## 附录 C：参考资源

### 官方文档

**Make:**
- GNU Make 手册: https://www.gnu.org/software/make/manual/
- Make 教程: https://makefiletutorial.com/

**CMake:**
- 官方文档: https://cmake.org/documentation/
- CMake Tutorial: https://cmake.org/cmake/help/latest/guide/tutorial/index.html
- Modern CMake: https://cliutils.gitlab.io/modern-cmake/

### 常用命令速查表

#### Make 速查表

```makefile
# 基本规则
target: dependencies
	command

# 变量
VAR = value
VAR := immediate_value
VAR ?= default_value
VAR += append

# 自动化变量
$@    # 目标
$<    # 第一个依赖
$^    # 所有依赖
$?    # 比目标新的依赖
$*    # 模式匹配的部分

# 函数
$(wildcard *.c)                    # 通配符
$(patsubst %.c,%.o,$(SOURCES))     # 模式替换
$(addprefix src/,$(FILES))         # 添加前缀
$(filter %.c,$(FILES))             # 过滤

# 条件
ifeq ($(VAR),value)
    ...
endif

# 伪目标
.PHONY: all clean

# 命令前缀
@command    # 不显示命令
-command    # 忽略错误
```

#### CMake 速查表

```cmake
# 项目设置
cmake_minimum_required(VERSION 3.15)
project(MyProject VERSION 1.0 LANGUAGES C CXX)

# 标准设置
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# 构建目标
add_executable(myapp main.cpp)
add_library(mylib STATIC lib.cpp)
add_library(mylib_shared SHARED lib.cpp)

# 目标属性
target_include_directories(myapp PRIVATE include)
target_link_libraries(myapp PRIVATE mylib)
target_compile_definitions(myapp PRIVATE DEBUG=1)
target_compile_options(myapp PRIVATE -Wall)

# 查找包
find_package(OpenSSL REQUIRED)
target_link_libraries(myapp PRIVATE OpenSSL::SSL)

# 选项
option(BUILD_TESTS "Build tests" ON)

# 条件
if(BUILD_TESTS)
    add_subdirectory(tests)
endif()

# 安装
install(TARGETS myapp DESTINATION bin)
install(FILES mylib.h DESTINATION include)

# 测试
enable_testing()
add_test(NAME test1 COMMAND mytest)

# 生成器表达式
$<$<CONFIG:Debug>:-g>
$<TARGET_FILE:myapp>
```

### 推荐阅读

**书籍：**
1. "Managing Projects with GNU Make" - Robert Mecklenburg
2. "Professional CMake: A Practical Guide" - Craig Scott
3. "The Linux Programming Interface" - Michael Kerrisk

**在线资源：**
1. CMake 最佳实践: https://github.com/cpp-best-practices/cmake_template
2. Awesome CMake: https://github.com/onqtam/awesome-cmake
3. CMake Examples: https://github.com/ttroy50/cmake-examples

**社区：**
1. Stack Overflow - cmake 标签
2. CMake Discourse: https://discourse.cmake.org/
3. Reddit - r/cmake

### 常见问题 FAQ

**Q: Make 和 CMake 应该选择哪个？**

A:
- 小型单平台项目：Make 更简单直接
- 跨平台项目：CMake 是更好的选择
- 大型 C++ 项目：建议使用 CMake
- 现有 Make 项目：可以继续使用，或逐步迁移到 CMake

**Q: 如何从 Make 迁移到 CMake？**

A:
1. 先创建简单的 CMakeLists.txt
2. 逐步添加目标和依赖
3. 保留原 Makefile 作为参考
4. 测试确保功能一致
5. 利用 CMake 的高级功能优化

**Q: 构建系统的性能如何优化？**

A:
- 使用并行编译 (`make -j`, `ninja`)
- 启用 ccache
- 减少不必要的依赖
- 使用预编译头文件
- 合理组织源文件

**Q: 如何处理跨平台差异？**

A: CMake 提供了很好的支持：
```cmake
if(WIN32)
    # Windows 特定代码
elseif(APPLE)
    # macOS 特定代码
elseif(UNIX)
    # Linux/Unix 特定代码
endif()
```

---

## 结语

恭喜你完成了 Make 和 CMake 教程的学习！

通过本教程，你应该掌握了：

1. **Make 基础**：Makefile 语法、依赖管理、增量编译
2. **Make 进阶**：模式规则、函数、多目录项目、并行编译
3. **CMake 基础**：CMakeLists.txt、目标、配置生成
4. **CMake 进阶**：Modern CMake、外部库、跨平台、测试、打包

### 继续学习的建议

1. **实践项目**：将所学应用到实际项目中
2. **阅读优秀项目的构建脚本**：如 LLVM、Qt、Boost
3. **关注最新发展**：CMake 持续更新，关注新特性
4. **深入系统知识**：编译链接原理、操作系统、工具链

### 资源导航

- **快速参考**：查看附录 C 的速查表
- **实战练习**：尝试附录 B 的项目
- **Linux 知识**：复习附录 A 的系统知识
- **问题求助**：善用 Stack Overflow 和官方文档

构建系统是软件工程的基础，掌握好 Make 和 CMake 将使你的开发效率大大提升。

祝你在软件开发的道路上越走越远！
