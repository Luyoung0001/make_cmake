# 第三部分：CMake 基础入门

## 3.1 CMake 简介与优势

### 什么是 CMake

CMake（Cross-platform Make）是一个跨平台的构建系统生成工具，由 Kitware 公司开发。它不直接构建项目，而是生成特定平台的构建文件（如 Unix Makefile、Visual Studio 项目文件、Xcode 项目等）。

**CMake 的工作流程：**
```
CMakeLists.txt → CMake → 构建文件 → 构建工具 → 可执行文件
                        ├─ Unix: Makefile
                        ├─ Windows: VS Solution
                        └─ macOS: Xcode Project
```

### CMake vs Make 的对比

| 特性 | Make | CMake |
|------|------|-------|
| **跨平台** | 否（主要用于 Unix） | 是（Windows/Linux/macOS） |
| **抽象层次** | 低（直接写编译命令） | 高（描述项目结构） |
| **复杂度** | 复杂项目难以维护 | 大项目更易管理 |
| **依赖管理** | 手动管理 | 自动化依赖查找 |
| **IDE 支持** | 有限 | 可生成 IDE 项目文件 |
| **学习曲线** | 陡峭（需了解 Shell） | 相对平缓 |
| **适用场景** | 小型项目、脚本 | 中大型跨平台项目 |

### 为什么需要 CMake

1. **跨平台开发**
   ```cmake
   # 同一份 CMakeLists.txt 可以在所有平台使用
   # Linux: 生成 Makefile
   # Windows: 生成 VS 项目
   # macOS: 生成 Xcode 项目
   ```

2. **简化依赖管理**
   ```cmake
   # 查找并使用第三方库
   find_package(OpenSSL REQUIRED)
   target_link_libraries(myapp OpenSSL::SSL)
   ```

3. **现代化构建系统**
   ```cmake
   # 目标导向的设计
   add_executable(myapp main.cpp)
   target_include_directories(myapp PRIVATE include)
   target_link_libraries(myapp mylib)
   ```

4. **更好的 IDE 集成**
   - VS Code、CLion、Visual Studio 等都原生支持 CMake
   - 自动代码补全、跳转、调试

### Ubuntu 环境下安装 CMake

```bash
# 检查是否已安装
cmake --version

# 从 apt 安装（可能不是最新版）
sudo apt update
sudo apt install cmake

# 安装最新版本（推荐）
# 方法 1: 从 Kitware 官方源安装
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
sudo apt update
sudo apt install cmake

# 方法 2: 从 Snap 安装
sudo snap install cmake --classic

# 方法 3: 下载预编译二进制
# 访问 https://cmake.org/download/
wget https://github.com/Kitware/CMake/releases/download/v3.28.0/cmake-3.28.0-linux-x86_64.tar.gz
tar -xzf cmake-3.28.0-linux-x86_64.tar.gz
sudo mv cmake-3.28.0-linux-x86_64 /opt/cmake
echo 'export PATH=/opt/cmake/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 验证安装
cmake --version
```

---

## 3.2 第一个 CMakeLists.txt

### 最小化的 CMakeLists.txt

**示例代码见：** `examples/cmake/01-hello-world/`

`hello.c`:
```c
#include <stdio.h>

int main() {
    printf("Hello, CMake!\n");
    return 0;
}
```

`CMakeLists.txt`:
```cmake
# 指定 CMake 最低版本
cmake_minimum_required(VERSION 3.10)

# 定义项目名称
project(HelloWorld)

# 添加可执行文件
add_executable(hello hello.c)
```

**关键命令说明：**
- `cmake_minimum_required`: 确保 CMake 版本兼容性
- `project`: 定义项目名称，会设置 `PROJECT_NAME` 等变量
- `add_executable`: 创建可执行目标

### cmake 命令的基本使用

```bash
# 方法 1: 源码外构建（推荐）
mkdir build
cd build
cmake ..        # 配置阶段：生成构建文件
make            # 或 cmake --build .（更通用）
./hello         # 运行程序

# 方法 2: 源码内构建（不推荐）
cmake .
make
./hello

# 清理
cd ..
rm -rf build    # 源码外构建很容易清理
```

**CMake 常用命令行选项：**
```bash
# 指定构建类型
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake -DCMAKE_BUILD_TYPE=Release ..

# 指定生成器
cmake -G "Unix Makefiles" ..
cmake -G "Ninja" ..
cmake -G "Visual Studio 16 2019" ..

# 指定安装路径
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..

# 查看所有可用选项
cmake -L ..
cmake -LH ..  # 带帮助信息

# 详细输出
cmake -DCMAKE_VERBOSE_MAKEFILE=ON ..

# 清除缓存
rm CMakeCache.txt
```

### 构建目录（out-of-source build）的概念

**源码内构建（不推荐）：**
```
project/
├── CMakeLists.txt
├── hello.c
├── CMakeCache.txt      # 生成的文件
├── CMakeFiles/         # 生成的目录
├── cmake_install.cmake
├── Makefile
└── hello
```
问题：生成文件与源文件混在一起，难以清理。

**源码外构建（推荐）：**
```
project/
├── CMakeLists.txt
├── hello.c
└── build/              # 所有生成的文件都在这里
    ├── CMakeCache.txt
    ├── CMakeFiles/
    ├── Makefile
    └── hello
```
优势：
- 源代码目录保持干净
- 可以创建多个构建目录（debug、release、不同编译器）
- 清理简单（直接删除 build 目录）

**多配置构建：**
```bash
# Debug 版本
mkdir build-debug && cd build-debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
make

# Release 版本
cd ..
mkdir build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
make

# 不同编译器
mkdir build-gcc && cd build-gcc
CC=gcc CXX=g++ cmake ..

cd ..
mkdir build-clang && cd build-clang
CC=clang CXX=clang++ cmake ..
```

### 案例：用 CMake 编译 Hello World

**完整示例见：** `examples/cmake/01-hello-world/`

**步骤详解：**

1. **创建项目目录**
```bash
mkdir hello-cmake
cd hello-cmake
```

2. **编写源代码** (`hello.c`)
```c
#include <stdio.h>

int main() {
    printf("Hello, CMake!\n");
    printf("CMake makes building easy!\n");
    return 0;
}
```

3. **编写 CMakeLists.txt**
```cmake
# CMake 最低版本要求
cmake_minimum_required(VERSION 3.10)

# 项目信息
project(HelloWorld VERSION 1.0)

# 添加可执行文件
add_executable(hello hello.c)
```

4. **配置和构建**
```bash
# 创建构建目录
mkdir build && cd build

# 配置项目（生成 Makefile）
cmake ..

# 观察输出：
# -- The C compiler identification is GNU 11.4.0
# -- Detecting C compiler ABI info
# -- Detecting C compiler ABI info - done
# -- Configuring done
# -- Generating done
# -- Build files have been written to: /path/to/build

# 构建项目
cmake --build .
# 或者
make

# 运行
./hello
```

5. **查看生成的文件**
```bash
ls -la
# CMakeCache.txt      - CMake 缓存文件
# CMakeFiles/         - CMake 内部文件
# Makefile            - 生成的 Makefile
# cmake_install.cmake - 安装脚本
# hello               - 可执行文件
```

6. **清理和重新构建**
```bash
# 清理构建产物
make clean

# 完全清理（删除所有生成的文件）
cd .. && rm -rf build

# 重新构建
mkdir build && cd build && cmake .. && make
```

**调试技巧：**
```bash
# 查看详细编译命令
make VERBOSE=1
# 或在 CMakeLists.txt 中添加：
# set(CMAKE_VERBOSE_MAKEFILE ON)

# 查看 CMake 变量
cmake -L ..
cmake -LA ..  # 包括高级变量
cmake -LAH .. # 包括帮助信息

# 使用 ccmake（图形化配置）
sudo apt install cmake-curses-gui
ccmake ..
```

---

## 3.3 CMake 基本命令

### project() 命令

```cmake
# 基本用法
project(MyProject)

# 完整用法
project(MyProject
    VERSION 1.2.3
    DESCRIPTION "My awesome project"
    LANGUAGES C CXX
)

# project() 会设置以下变量：
# PROJECT_NAME              - 项目名称
# PROJECT_VERSION           - 1.2.3
# PROJECT_VERSION_MAJOR     - 1
# PROJECT_VERSION_MINOR     - 2
# PROJECT_VERSION_PATCH     - 3
# PROJECT_DESCRIPTION       - 项目描述
# PROJECT_SOURCE_DIR        - 顶层源目录
# PROJECT_BINARY_DIR        - 顶层构建目录
# <PROJECT_NAME>_SOURCE_DIR
# <PROJECT_NAME>_BINARY_DIR
```

### add_executable() 命令

```cmake
# 基本用法
add_executable(myapp main.c)

# 多个源文件
add_executable(myapp main.c utils.c helper.c)

# 使用变量
set(SOURCES main.c utils.c helper.c)
add_executable(myapp ${SOURCES})

# 自动查找源文件（不推荐用于生产代码）
file(GLOB SOURCES "src/*.c")
add_executable(myapp ${SOURCES})

# 推荐方式：显式列出
add_executable(myapp
    src/main.c
    src/utils.c
    src/helper.c
)
```

### add_library() 命令

```cmake
# 静态库
add_library(mylib STATIC
    lib/mylib.c
    lib/helper.c
)

# 动态库（共享库）
add_library(mylib SHARED
    lib/mylib.c
    lib/helper.c
)

# 默认类型（由 BUILD_SHARED_LIBS 控制）
add_library(mylib
    lib/mylib.c
    lib/helper.c
)

# 接口库（仅包含头文件）
add_library(mylib INTERFACE)
target_include_directories(mylib INTERFACE include/)

# 对象库（编译但不链接）
add_library(mylib OBJECT
    lib/mylib.c
)
add_executable(myapp main.c $<TARGET_OBJECTS:mylib>)
```

### set() 命令

```cmake
# 设置变量
set(MY_VAR "Hello")
set(MY_VAR "Hello" PARENT_SCOPE)  # 设置父作用域变量

# 设置列表
set(SOURCES main.c utils.c)
set(SOURCES main.c;utils.c)  # 等价写法

# 追加到列表
list(APPEND SOURCES helper.c)

# 设置缓存变量
set(MY_OPTION "default" CACHE STRING "Description")

# 设置环境变量
set(ENV{PATH} "/new/path:$ENV{PATH}")

# 常用的内置变量设置
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE Release)
```

### message() 命令

```cmake
# 不同级别的消息
message(STATUS "This is a status message")
message(WARNING "This is a warning")
message(AUTHOR_WARNING "Warning for project authors")
message(SEND_ERROR "This is an error, but continue processing")
message(FATAL_ERROR "This is a fatal error, stop processing")

# 调试输出
message("Value of MY_VAR: ${MY_VAR}")
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")

# 条件消息
if(DEBUG_MODE)
    message(STATUS "Debug mode enabled")
endif()

# 格式化输出
message(STATUS "----------------------------------------")
message(STATUS "Configuration Summary:")
message(STATUS "  Project: ${PROJECT_NAME}")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "----------------------------------------")
```

### 案例：编译可执行文件和静态库

**示例代码见：** `examples/cmake/02-library/`

项目结构：
```
02-library/
├── CMakeLists.txt
├── src/
│   └── main.c
├── lib/
│   ├── mathlib.c
│   └── mathlib.h
└── include/
```

`lib/mathlib.h`:
```c
#ifndef MATHLIB_H
#define MATHLIB_H

int add(int a, int b);
int subtract(int a, int b);
int multiply(int a, int b);
int divide(int a, int b);

#endif
```

`lib/mathlib.c`:
```c
#include "mathlib.h"

int add(int a, int b) { return a + b; }
int subtract(int a, int b) { return a - b; }
int multiply(int a, int b) { return a * b; }
int divide(int a, int b) { return b != 0 ? a / b : 0; }
```

`src/main.c`:
```c
#include <stdio.h>
#include "mathlib.h"

int main() {
    printf("10 + 5 = %d\n", add(10, 5));
    printf("10 - 5 = %d\n", subtract(10, 5));
    printf("10 * 5 = %d\n", multiply(10, 5));
    printf("10 / 5 = %d\n", divide(10, 5));
    return 0;
}
```

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.10)
project(MathApp VERSION 1.0 LANGUAGES C)

# 设置 C 标准
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

# 打印配置信息
message(STATUS "Building ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# 创建静态库
add_library(mathlib STATIC
    lib/mathlib.c
)

# 为库设置包含目录（PUBLIC 表示使用者也会包含这个目录）
target_include_directories(mathlib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

# 创建可执行文件
add_executable(mathapp
    src/main.c
)

# 链接库
target_link_libraries(mathapp PRIVATE mathlib)

# 打印构建信息
message(STATUS "Executable: mathapp")
message(STATUS "Library: mathlib (STATIC)")
```

**编译和运行：**
```bash
mkdir build && cd build
cmake ..
make
./mathapp
```

**输出文件：**
```bash
ls -lh
# libmathlib.a - 静态库
# mathapp      - 可执行文件
```

**查看静态库内容：**
```bash
ar -t libmathlib.a
# mathlib.c.o

nm libmathlib.a
# 显示库中的符号
```

---

## 3.4 CMake 的工作原理

### CMake 生成 Makefile 的过程

CMake 构建过程分为两个阶段：

**1. 配置阶段（Configure）**
```bash
cmake ..
```

这个阶段 CMake 会：
- 读取 `CMakeLists.txt`
- 检测编译器和工具链
- 处理 `find_package()` 等命令
- 解析变量和条件语句
- 生成 `CMakeCache.txt`（缓存配置结果）

**2. 生成阶段（Generate）**

紧接着配置阶段，CMake 会：
- 根据配置结果生成构建文件
- 对于 Unix：生成 `Makefile`
- 对于 Windows：生成 `.sln` 和 `.vcxproj` 文件
- 对于 macOS：生成 Xcode 项目文件

**完整流程：**
```
CMakeLists.txt
     ↓
[Configure] → CMakeCache.txt
     ↓
[Generate]  → Makefile / VS Solution / Xcode Project
     ↓
[Build]     → make / msbuild / xcodebuild
     ↓
Executable / Library
```

### 配置阶段与生成阶段

**示例代码见：** `examples/cmake/03-two-stages/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.10)
project(TwoStages)

# 配置阶段执行
message(STATUS "========== Configure Stage ==========")
message(STATUS "Reading CMakeLists.txt...")
message(STATUS "Detecting compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# 检测系统
if(UNIX)
    message(STATUS "Platform: Unix-like")
elseif(WIN32)
    message(STATUS "Platform: Windows")
endif()

# 添加可执行文件（配置阶段记录，生成阶段处理）
add_executable(app main.c)

message(STATUS "========== Generate Stage Next ==========")
```

运行 cmake 时的输出：
```bash
$ cmake ..
-- The C compiler identification is GNU 11.4.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- ========== Configure Stage ==========
-- Reading CMakeLists.txt...
-- Detecting compiler: /usr/bin/cc
-- Build type:
-- Platform: Unix-like
-- ========== Generate Stage Next ==========
-- Configuring done
-- Generating done
-- Build files have been written to: /path/to/build
```

### CMakeCache.txt 的作用

`CMakeCache.txt` 保存了配置阶段的所有结果，包括：
- 检测到的编译器路径
- 找到的第三方库位置
- 用户设置的选项
- 系统信息

**查看缓存：**
```bash
cat CMakeCache.txt
# 或使用 cmake-gui / ccmake
```

**缓存内容示例：**
```cmake
//Path to a program.
CMAKE_AR:FILEPATH=/usr/bin/ar

//Choose the type of build, options are: None Debug Release...
CMAKE_BUILD_TYPE:STRING=

//C compiler
CMAKE_C_COMPILER:FILEPATH=/usr/bin/cc

//Flags used by the C compiler during all build types.
CMAKE_C_FLAGS:STRING=

//Install path prefix, prepended onto install directories.
CMAKE_INSTALL_PREFIX:PATH=/usr/local
```

**修改缓存：**
```bash
# 方法 1: 命令行
cmake -DCMAKE_BUILD_TYPE=Debug ..

# 方法 2: 编辑 CMakeCache.txt
# 修改后需要重新运行 cmake

# 方法 3: 使用 ccmake（推荐）
ccmake ..

# 清除缓存
rm CMakeCache.txt
cmake ..
```

**缓存变量类型：**
```cmake
# BOOL: ON/OFF
option(ENABLE_TESTS "Enable testing" ON)

# STRING: 字符串
set(MY_STRING "value" CACHE STRING "Description")

# FILEPATH: 文件路径
set(CONFIG_FILE "config.txt" CACHE FILEPATH "Config file")

# PATH: 目录路径
set(INSTALL_DIR "/usr/local" CACHE PATH "Install directory")

# INTERNAL: 内部变量（用户不可见）
set(INTERNAL_VAR "value" CACHE INTERNAL "")
```

### 案例：查看生成的 Makefile 并理解其结构

**示例代码见：** `examples/cmake/04-makefile-analysis/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.10)
project(MakefileAnalysis)

# 启用详细输出
set(CMAKE_VERBOSE_MAKEFILE ON)

add_executable(app main.c utils.c)
```

**生成并查看 Makefile：**
```bash
mkdir build && cd build
cmake ..
cat Makefile
```

**生成的 Makefile 结构：**
```makefile
# 顶层 Makefile（简化版）

# CMake 生成的文件不要手动编辑
# Generated by CMake ...

# 默认目标
default_target: all

# 特殊目标
.PHONY : all clean depend

all: cmake_check_build_system
	$(CMAKE_COMMAND) -E cmake_progress_start ...
	$(MAKE) -f CMakeFiles/Makefile2 all
	$(CMAKE_COMMAND) -E cmake_progress_start ... 0

# 清理
clean:
	$(MAKE) -f CMakeFiles/Makefile2 clean

# 依赖检查
depend:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 0

# 构建特定目标
app: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 app

# 快速构建（跳过依赖检查）
app/fast:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/build
```

**CMakeFiles/Makefile2（第二层）：**
```makefile
# 包含所有目标的规则
CMakeFiles/app.dir/all:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/depend
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/build
```

**CMakeFiles/app.dir/build.make（第三层）：**
```makefile
# 实际的编译命令
CMakeFiles/app.dir/main.c.o: ../main.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=...
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o $@ -c $<

CMakeFiles/app.dir/utils.c.o: ../utils.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=...
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o $@ -c $<

# 链接
app: CMakeFiles/app.dir/main.c.o CMakeFiles/app.dir/utils.c.o
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/app.dir/link.txt --verbose=$(VERBOSE)
```

**关键发现：**

1. **分层结构**：CMake 生成三层 Makefile
   - `Makefile`：用户界面，提供常用目标
   - `CMakeFiles/Makefile2`：管理所有目标
   - `CMakeFiles/*/build.make`：实际编译命令

2. **自动依赖**：CMake 自动生成 `.c.o.d` 依赖文件

3. **增量编译**：与手写 Makefile 一样支持增量编译

4. **灵活性**：可以构建特定目标
   ```bash
   make app        # 构建 app
   make app/fast   # 快速构建，跳过依赖检查
   ```

**CMake 相比手写 Makefile 的优势：**
```bash
# 使用 CMake
cmake .. && make

# 等价的手写 Makefile（需要手动写很多内容）
# - 编译器检测
# - 平台差异处理
# - 依赖自动生成
# - 进度显示
# - 颜色输出
# - 等等...
```

---

## 小结

在这一章中，我们学习了 CMake 的基础知识：

1. **CMake 简介**：跨平台构建系统生成工具
2. **第一个项目**：最简 CMakeLists.txt 和源码外构建
3. **基本命令**：`project()`、`add_executable()`、`add_library()`、`set()`、`message()`
4. **工作原理**：配置-生成-构建三阶段，CMakeCache.txt 的作用

CMake 提供了比 Make 更高层次的抽象，使得跨平台项目管理变得简单。

下一章我们将学习 CMake 的进阶应用，包括目标属性、外部库查找、多目录项目等。
