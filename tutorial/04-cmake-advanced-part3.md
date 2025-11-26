# CMake 进阶应用（续）

## 4.7 交叉编译与工具链

### CMAKE_TOOLCHAIN_FILE

工具链文件（Toolchain File）定义了交叉编译所需的编译器和工具。

**基本结构：**
```cmake
# toolchain-arm.cmake

# 目标系统信息
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 交叉编译器
set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# 查找库和头文件的根目录
set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabihf)

# 调整搜索行为
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)  # 不在目标系统查找程序
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)   # 只在目标系统查找库
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)   # 只在目标系统查找头文件

# 额外标志
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv7-a" CACHE STRING "" FORCE)
```

使用工具链文件：
```bash
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm.cmake ..
```

### 常见平台的工具链

**ARM Linux：**
```cmake
# toolchain-arm-linux.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CROSS_COMPILE arm-linux-gnueabihf-)

set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})

set(CMAKE_FIND_ROOT_PATH /usr/${CROSS_COMPILE})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```

**Windows (MinGW)：**
```cmake
# toolchain-mingw.cmake
set(CMAKE_SYSTEM_NAME Windows)

set(TOOLCHAIN_PREFIX x86_64-w64-mingw32)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)

set(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

**Android：**
```cmake
# toolchain-android.cmake
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 28)  # API Level
set(CMAKE_ANDROID_ARCH_ABI armeabi-v7a)
set(CMAKE_ANDROID_NDK /path/to/android-ndk)
set(CMAKE_ANDROID_STL_TYPE c++_shared)
```

### Linux 知识穿插：系统架构、链接器、动态库

**系统架构检测：**
```cmake
# 检测目标架构
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)")
    set(ARCH_ARM64 TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm")
    set(ARCH_ARM TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)")
    set(ARCH_X86_64 TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i.86|x86|X86)")
    set(ARCH_X86 TRUE)
endif()

message(STATUS "Target architecture: ${CMAKE_SYSTEM_PROCESSOR}")
```

**链接器选项：**
```cmake
# 设置 RPATH（运行时库搜索路径）
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Linux: 设置 SONAME
set_target_properties(mylib PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# 链接器脚本
target_link_options(myapp PRIVATE
    -Wl,--version-script=${CMAKE_SOURCE_DIR}/mylib.map
)

# 查看依赖
# ldd myapp
# readelf -d myapp
```

**动态库 vs 静态库：**
```cmake
# 构建静态库和动态库
add_library(mylib_static STATIC src/lib.c)
add_library(mylib_shared SHARED src/lib.c)

# 统一名称
set_target_properties(mylib_static PROPERTIES OUTPUT_NAME mylib)
set_target_properties(mylib_shared PROPERTIES OUTPUT_NAME mylib)

# 控制符号可见性
set_target_properties(mylib_shared PROPERTIES
    C_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)

target_compile_definitions(mylib_shared PRIVATE
    BUILDING_MYLIB  # 导出符号
)

# 使用方式
if(BUILD_SHARED_LIBS)
    add_library(mylib SHARED src/lib.c)
else()
    add_library(mylib STATIC src/lib.c)
endif()
```

### 案例：为 ARM 平台交叉编译

**示例代码见：** `examples/cmake/11-cross-compile/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(CrossCompileDemo VERSION 1.0)

set(CMAKE_C_STANDARD 11)

# 打印目标平台信息
message(STATUS "========================================")
message(STATUS "Cross-compilation information:")
message(STATUS "  System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  Processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C Compiler ID: ${CMAKE_C_COMPILER_ID}")
message(STATUS "  C Compiler Version: ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "========================================")

# 检查编译器特性
include(CheckCCompilerFlag)
check_c_compiler_flag(-mfpu=neon HAS_NEON)
if(HAS_NEON)
    message(STATUS "NEON support available")
    add_compile_options(-mfpu=neon)
endif()

# 创建应用
add_executable(cross_demo
    main.c
    platform_info.c
)

# 平台特定设置
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    target_compile_definitions(cross_demo PRIVATE
        ARM_PLATFORM
        ARM_ARCH="${CMAKE_SYSTEM_PROCESSOR}"
    )
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    target_compile_definitions(cross_demo PRIVATE
        X86_64_PLATFORM
    )
endif()

# 链接数学库（可能需要）
target_link_libraries(cross_demo PRIVATE m)

# 显示构建信息
add_custom_command(TARGET cross_demo POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Built for: ${CMAKE_SYSTEM_PROCESSOR}"
    COMMAND file $<TARGET_FILE:cross_demo>
)
```

`toolchain-arm.cmake`:
```cmake
# ARM Linux 交叉编译工具链

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 工具链前缀
set(CROSS_COMPILE arm-linux-gnueabihf-)

# 编译器
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_STRIP ${CROSS_COMPILE}strip)
set(CMAKE_AR ${CROSS_COMPILE}ar)
set(CMAKE_RANLIB ${CROSS_COMPILE}ranlib)

# Sysroot（如果有）
# set(CMAKE_SYSROOT /path/to/sysroot)

# 查找路径
set(CMAKE_FIND_ROOT_PATH /usr/${CROSS_COMPILE})

# 搜索模式
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# 编译标志
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv7-a -mfpu=neon" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a -mfpu=neon" CACHE STRING "")
```

`main.c`:
```c
#include <stdio.h>

extern void print_platform_info(void);

int main() {
    printf("Cross-compilation demo\n");
    printf("======================\n\n");

    print_platform_info();

#ifdef ARM_PLATFORM
    printf("Running on ARM platform\n");
    printf("Architecture: %s\n", ARM_ARCH);
#endif

#ifdef X86_64_PLATFORM
    printf("Running on x86_64 platform\n");
#endif

    return 0;
}
```

`platform_info.c`:
```c
#include <stdio.h>
#include <sys/utsname.h>

void print_platform_info(void) {
    struct utsname info;

    if (uname(&info) == 0) {
        printf("Platform Information:\n");
        printf("  System: %s\n", info.sysname);
        printf("  Node: %s\n", info.nodename);
        printf("  Release: %s\n", info.release);
        printf("  Version: %s\n", info.version);
        printf("  Machine: %s\n", info.machine);
    }

    printf("\nCompiler Information:\n");
    printf("  Compiled with: GCC %d.%d.%d\n",
           __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);

#ifdef __arm__
    printf("  Target: ARM\n");
#endif

#ifdef __aarch64__
    printf("  Target: ARM64\n");
#endif

#ifdef __x86_64__
    printf("  Target: x86_64\n");
#endif

    printf("  Pointer size: %zu bytes\n", sizeof(void*));
}
```

**编译和测试：**
```bash
# 安装交叉编译工具链
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

# 本地编译（用于对比）
mkdir build-native && cd build-native
cmake ..
make
file cross_demo
./cross_demo

# ARM 交叉编译
cd ..
mkdir build-arm && cd build-arm
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm.cmake ..
make
file cross_demo

# 查看二进制信息
readelf -h cross_demo
arm-linux-gnueabihf-readelf -A cross_demo

# 在 ARM 设备或 QEMU 上运行
# qemu-arm -L /usr/arm-linux-gnueabihf ./cross_demo
```

---

## 4.8 测试与集成

### enable_testing() 和 add_test()

```cmake
# 启用测试
enable_testing()

# 添加测试
add_test(NAME test1 COMMAND mytest arg1 arg2)

# 设置测试属性
set_tests_properties(test1 PROPERTIES
    PASS_REGULAR_EXPRESSION "Test passed"
    TIMEOUT 10
)

# 多个测试
add_executable(test_math test_math.c)
add_test(NAME MathTests COMMAND test_math)

add_executable(test_string test_string.c)
add_test(NAME StringTests COMMAND test_string)
```

### CTest 的使用

**基本用法：**
```cmake
include(CTest)

add_test(NAME quick_test COMMAND quick_test)
add_test(NAME slow_test COMMAND slow_test)

# 设置测试标签
set_tests_properties(quick_test PROPERTIES LABELS "quick;unit")
set_tests_properties(slow_test PROPERTIES LABELS "slow;integration")

# 设置超时
set_tests_properties(slow_test PROPERTIES TIMEOUT 300)

# 设置工作目录
set_tests_properties(quick_test PROPERTIES
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test_data
)

# 设置环境变量
set_tests_properties(quick_test PROPERTIES
    ENVIRONMENT "TEST_DATA_DIR=${CMAKE_SOURCE_DIR}/data"
)
```

运行测试：
```bash
# 运行所有测试
ctest

# 详细输出
ctest -V
ctest --verbose

# 运行特定测试
ctest -R Math    # 正则匹配
ctest -L quick   # 按标签

# 并行运行
ctest -j4

# 重新运行失败的测试
ctest --rerun-failed

# 输出到文件
ctest -T Test -V --output-log test_log.txt
```

### 与 CI/CD 集成

**GitHub Actions 示例：**
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Install dependencies
      run: sudo apt-get install -y cmake build-essential

    - name: Configure
      run: cmake -B build -DCMAKE_BUILD_TYPE=Release

    - name: Build
      run: cmake --build build

    - name: Test
      run: cd build && ctest --output-on-failure
```

**CMake 配置：**
```cmake
# 自动生成 CTest 配置
include(CTest)

# 添加测试覆盖率
option(ENABLE_COVERAGE "Enable coverage reporting" OFF)

if(ENABLE_COVERAGE AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(mylib PRIVATE --coverage)
    target_link_options(mylib PRIVATE --coverage)

    # 添加覆盖率目标
    add_custom_target(coverage
        COMMAND lcov --directory . --capture --output-file coverage.info
        COMMAND lcov --remove coverage.info '/usr/*' --output-file coverage.info
        COMMAND lcov --list coverage.info
        COMMAND genhtml coverage.info --output-directory coverage_html
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Generating coverage report"
    )
endif()
```

### 案例：构建完整的测试框架

**示例代码见：** `examples/cmake/12-testing/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(TestFramework VERSION 1.0)

set(CMAKE_C_STANDARD 11)

# 选项
option(BUILD_TESTING "Build tests" ON)
option(ENABLE_COVERAGE "Enable coverage" OFF)

# ========== 主库 ==========
add_library(mathlib STATIC
    src/math_ops.c
    src/string_ops.c
)

target_include_directories(mathlib PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)

# ========== 测试 ==========
if(BUILD_TESTING)
    enable_testing()
    include(CTest)

    # 简单测试框架（可替换为 Google Test 等）
    add_library(testlib STATIC
        tests/test_framework.c
    )

    # 数学测试
    add_executable(test_math tests/test_math.c)
    target_link_libraries(test_math PRIVATE mathlib testlib)
    add_test(NAME MathTests COMMAND test_math)

    # 字符串测试
    add_executable(test_string tests/test_string.c)
    target_link_libraries(test_string PRIVATE mathlib testlib)
    add_test(NAME StringTests COMMAND test_string)

    # 集成测试
    add_executable(test_integration tests/test_integration.c)
    target_link_libraries(test_integration PRIVATE mathlib testlib)
    add_test(NAME IntegrationTests COMMAND test_integration)

    # 设置测试属性
    set_tests_properties(MathTests PROPERTIES
        LABELS "unit;math"
        TIMEOUT 10
    )

    set_tests_properties(StringTests PROPERTIES
        LABELS "unit;string"
        TIMEOUT 10
    )

    set_tests_properties(IntegrationTests PROPERTIES
        LABELS "integration"
        TIMEOUT 30
    )

    # 性能测试（默认不运行）
    add_executable(benchmark_math tests/benchmark_math.c)
    target_link_libraries(benchmark_math PRIVATE mathlib)
    add_test(NAME PerformanceTests COMMAND benchmark_math)
    set_tests_properties(PerformanceTests PROPERTIES
        LABELS "benchmark"
        DISABLED TRUE  # 默认禁用
    )

    # 覆盖率
    if(ENABLE_COVERAGE)
        target_compile_options(mathlib PRIVATE --coverage)
        target_link_options(mathlib PRIVATE --coverage)

        add_custom_target(coverage
            COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
            COMMAND lcov --directory . --capture --output-file coverage.info
            COMMAND lcov --remove coverage.info '*/tests/*' '/usr/*' --output-file coverage.info
            COMMAND lcov --list coverage.info
            COMMAND genhtml coverage.info --output-directory coverage_html
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating coverage report"
        )
    endif()

    # 测试辅助目标
    add_custom_target(check
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        DEPENDS test_math test_string test_integration
        COMMENT "Running all tests"
    )

    add_custom_target(quick-test
        COMMAND ${CMAKE_CTEST_COMMAND} -L unit --output-on-failure
        COMMENT "Running quick unit tests"
    )
endif()

# ========== 安装 ==========
install(TARGETS mathlib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/
    DESTINATION include
)

# ========== 打印配置摘要 ==========
message(STATUS "========================================")
message(STATUS "Test Configuration:")
message(STATUS "  Build tests: ${BUILD_TESTING}")
message(STATUS "  Enable coverage: ${ENABLE_COVERAGE}")
message(STATUS "========================================")
```

`tests/test_framework.h`:
```c
#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

#include <stdio.h>

#define TEST_ASSERT(condition, message) \
    do { \
        if (!(condition)) { \
            fprintf(stderr, "FAIL: %s:%d: %s\n", __FILE__, __LINE__, message); \
            return 1; \
        } \
    } while(0)

#define TEST_ASSERT_EQ(a, b, message) \
    TEST_ASSERT((a) == (b), message)

#define RUN_TEST(test) \
    do { \
        printf("Running %s...\n", #test); \
        if (test() != 0) { \
            fprintf(stderr, "Test %s FAILED\n", #test); \
            return 1; \
        } \
        printf("Test %s PASSED\n", #test); \
    } while(0)

#endif
```

`tests/test_math.c`:
```c
#include "test_framework.h"
#include "mathlib.h"

int test_add() {
    TEST_ASSERT_EQ(add(2, 3), 5, "2 + 3 should equal 5");
    TEST_ASSERT_EQ(add(-1, 1), 0, "-1 + 1 should equal 0");
    TEST_ASSERT_EQ(add(0, 0), 0, "0 + 0 should equal 0");
    return 0;
}

int test_subtract() {
    TEST_ASSERT_EQ(subtract(5, 3), 2, "5 - 3 should equal 2");
    TEST_ASSERT_EQ(subtract(0, 0), 0, "0 - 0 should equal 0");
    return 0;
}

int test_multiply() {
    TEST_ASSERT_EQ(multiply(3, 4), 12, "3 * 4 should equal 12");
    TEST_ASSERT_EQ(multiply(0, 100), 0, "0 * 100 should equal 0");
    return 0;
}

int main() {
    printf("=== Math Tests ===\n");
    RUN_TEST(test_add);
    RUN_TEST(test_subtract);
    RUN_TEST(test_multiply);
    printf("All tests passed!\n");
    return 0;
}
```

**运行测试：**
```bash
mkdir build && cd build

# 配置
cmake .. -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Debug

# 构建
make

# 运行所有测试
ctest
# 或
make check

# 运行快速测试
make quick-test

# 详细输出
ctest -V

# 运行特定标签的测试
ctest -L unit
ctest -L integration

# 生成覆盖率报告（需要 lcov）
cmake .. -DENABLE_COVERAGE=ON
make coverage
# 查看 coverage_html/index.html
```

---

## 4.9 现代 CMake 最佳实践

### 目标导向的 CMake（Modern CMake）

**核心原则：**
1. **以目标（Target）为中心**
2. **使用 `target_*` 命令而不是全局命令**
3. **正确使用可见性（PUBLIC/PRIVATE/INTERFACE）**
4. **导出和安装目标，而不是变量**

**不好的实践（Old CMake）：**
```cmake
# 全局设置，影响所有目标
include_directories(${PROJECT_SOURCE_DIR}/include)
link_directories(${PROJECT_SOURCE_DIR}/lib)
add_definitions(-DDEBUG)

# 使用变���传递依赖
set(MY_LIBS lib1 lib2 lib3)
set(MY_INCLUDES /path/to/includes)

add_executable(myapp main.c)
target_link_libraries(myapp ${MY_LIBS})
include_directories(${MY_INCLUDES})
```

**好的实践（Modern CMake）：**
```cmake
# 目标特定设置
add_library(mylib src/lib.c)

target_include_directories(mylib
    PUBLIC include/     # 公共 API
    PRIVATE src/        # 内部实现
)

target_compile_definitions(mylib
    PUBLIC MYLIB_VERSION=1
    PRIVATE DEBUG_MODE
)

# 使用导入目标
add_executable(myapp main.c)
target_link_libraries(myapp PRIVATE mylib)  # 自动继承 mylib 的属性
```

### 避免使用全局命令

**应避免：**
```cmake
include_directories(...)    # 全局包含
link_directories(...)       # 全局库目录
add_definitions(...)        # 全局宏定义
```

**应使用：**
```cmake
target_include_directories(target ...)
target_link_libraries(target ...)
target_compile_definitions(target ...)
target_compile_options(target ...)
target_sources(target ...)
```

### 可重用的 CMake 模块

**创建可重用的 CMake 函数：**

`cmake/WarningFlags.cmake`:
```cmake
# 为目标添加编译器警告
function(target_set_warnings TARGET_NAME)
    set(MSVC_WARNINGS
        /W4  # 警告级别 4
        /WX  # 警告视为错误
    )

    set(GCC_CLANG_WARNINGS
        -Wall
        -Wextra
        -Wpedantic
        -Werror
    )

    if(CMAKE_C_COMPILER_ID MATCHES "MSVC")
        set(WARNINGS ${MSVC_WARNINGS})
    else()
        set(WARNINGS ${GCC_CLANG_WARNINGS})
    endif()

    target_compile_options(${TARGET_NAME} PRIVATE ${WARNINGS})
endfunction()
```

使用：
```cmake
include(cmake/WarningFlags.cmake)

add_executable(myapp main.c)
target_set_warnings(myapp)
```

**创建可查找的包：**

`MyLibConfig.cmake.in`:
```cmake
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/MyLibTargets.cmake")

check_required_components(MyLib)
```

`CMakeLists.txt`:
```cmake
# 安装导出目标
install(TARGETS mylib
    EXPORT MyLibTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(EXPORT MyLibTargets
    FILE MyLibTargets.cmake
    NAMESPACE MyLib::
    DESTINATION lib/cmake/MyLib
)

# 生成配置文件
include(CMakePackageConfigHelpers)

configure_package_config_file(
    cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyLib
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    DESTINATION lib/cmake/MyLib
)
```

使用安装的库：
```cmake
find_package(MyLib REQUIRED)
target_link_libraries(myapp PRIVATE MyLib::mylib)
```

### 案例：编写一个可供其他项目使用的 CMake 库

**示例代码见：** `examples/cmake/13-reusable-library/`

完整示例见文件，包含：
1. 库的 CMakeLists.txt（支持导出）
2. 配置文件模板
3. 使用该库的示例项目

---

## 4.10 调试与优化

### CMAKE_VERBOSE_MAKEFILE

```cmake
# 在 CMakeLists.txt 中设置
set(CMAKE_VERBOSE_MAKEFILE ON)

# 或在命令行
cmake -DCMAKE_VERBOSE_MAKEFILE=ON ..

# 或构建时
make VERBOSE=1
cmake --build . --verbose
```

### --trace 等调试选项

```bash
# 跟踪所有 CMake 命令
cmake --trace ..

# 跟踪特定文件
cmake --trace-source=CMakeLists.txt ..

# 更详细的跟踪
cmake --trace-expand ..

# 查看变量
cmake -L ..        # 列出缓存变量
cmake -LA ..       # 列出所有变量
cmake -LAH ..      # 列出所有变量及帮助

# 图形化配置（需要安装）
cmake-gui ..
ccmake ..

# 打印依赖关系图
cmake --graphviz=deps.dot ..
dot -Tpng deps.dot -o deps.png
```

### 常见问题排查

**问题 1: 找不到库或头文件**
```cmake
# 显示查找路径
message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message(STATUS "CMAKE_INCLUDE_PATH: ${CMAKE_INCLUDE_PATH}")
message(STATUS "CMAKE_LIBRARY_PATH: ${CMAKE_LIBRARY_PATH}")

# 手动指定路径
set(CMAKE_PREFIX_PATH /custom/path ${CMAKE_PREFIX_PATH})

# 或使用 hint
find_package(MyLib HINTS /custom/path)
```

**问题 2: 编译器未正确检测**
```bash
# 指定编译器
CC=gcc CXX=g++ cmake ..

# 或
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ ..
```

**问题 3: 缓存问题**
```bash
# 清除缓存
rm CMakeCache.txt
rm -rf CMakeFiles/
cmake ..

# 或完全重新开始
rm -rf build && mkdir build && cd build && cmake ..
```

**调试函数：**
```cmake
# 打印变量的辅助函数
function(dump_variable VAR_NAME)
    if(DEFINED ${VAR_NAME})
        message(STATUS "${VAR_NAME} = ${${VAR_NAME}}")
    else()
        message(STATUS "${VAR_NAME} is not defined")
    endif()
endfunction()

# 打印所有以特定前缀开头的变量
function(dump_variables_with_prefix PREFIX)
    get_cmake_property(_variableNames VARIABLES)
    foreach(_variableName ${_variableNames})
        if(_variableName MATCHES "^${PREFIX}")
            message(STATUS "${_variableName} = ${${_variableName}}")
        endif()
    endforeach()
endfunction()

# 使用
dump_variable(CMAKE_BUILD_TYPE)
dump_variables_with_prefix("CMAKE_C")
```

### 性能优化

```cmake
# 并行构建
cmake --build . -j$(nproc)

# 使用 Ninja 生成器（比 Make 快）
cmake -G Ninja ..
ninja

# 使用 ccache
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

# 减少不必要的重新配置
file(GLOB_RECURSE SOURCES "src/*.c")  # 不推荐
# 改为显式列出文件，或使用 configure_file 生成列表
```

---

## 小结

在 CMake 进阶部分，我们学习了：

1. **目标属性**：Modern CMake 的核心设计理念
2. **外部库**：使用 find_package 集成第三方库
3. **多目录项目**：大型项目的组织结构
4. **生成器表达式**：灵活的条件配置
5. **自定义命令**：集成代码生成等自定义步骤
6. **安装打包**：使用 install 和 CPack
7. **交叉编译**：工具链文件和跨平台构建
8. **测试集成**：CTest 和 CI/CD
9. **最佳实践**：Modern CMake 编程范式
10. **调试技巧**：排查和优化 CMake 项目

CMake 提供了强大而灵活的构建系统，掌握这些进阶技巧能够帮助你构建和维护复杂的跨平台项目。
