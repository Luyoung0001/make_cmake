# 第四部分：CMake 进阶应用

## 4.1 目标（Target）与属性

### Modern CMake 的核心思想

Modern CMake（CMake 3.0+）强调**目标导向**的设计，而不是基于目录或全局变量。

**传统方式（不推荐）：**
```cmake
include_directories(include)
link_directories(lib)
add_definitions(-DDEBUG)

add_executable(myapp main.c)
```
问题：影响之后所有目标，容易产生冲突。

**现代方式（推荐）：**
```cmake
add_executable(myapp main.c)
target_include_directories(myapp PRIVATE include)
target_link_libraries(myapp PRIVATE mylib)
target_compile_definitions(myapp PRIVATE DEBUG)
```
优势：每个目标独立配置，清晰明确。

### target_include_directories()

```cmake
# 基本用法
target_include_directories(mytarget
    PRIVATE   include/private     # 仅目标本身使用
    PUBLIC    include/public      # 目标和使用者都使用
    INTERFACE include/interface   # 仅使用者使用
)

# 实际示例
add_library(mylib src/lib.c)
target_include_directories(mylib
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include  # 公共头文件
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src      # 私有头文件
)

add_executable(myapp main.c)
target_link_libraries(myapp PRIVATE mylib)  # 自动继承 mylib 的 PUBLIC 包含目录
```

### target_link_libraries()

```cmake
# 链接库
target_link_libraries(myapp
    PRIVATE mylib              # 私有依赖
    PUBLIC  another_lib        # 公共依赖
    INTERFACE interface_lib    # 接口依赖
)

# 链接系统库
target_link_libraries(myapp PRIVATE pthread m)

# 链接绝对路径库
target_link_libraries(myapp PRIVATE /usr/local/lib/libfoo.a)

# 条件链接
if(WIN32)
    target_link_libraries(myapp PRIVATE ws2_32)
endif()
```

### target_compile_options()

```cmake
# 添加编译选项
target_compile_options(myapp PRIVATE
    -Wall
    -Wextra
    -Werror
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3>
)

# 不同编译器的选项
target_compile_options(myapp PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-fno-exceptions>
    $<$<CXX_COMPILER_ID:Clang>:-fno-rtti>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)
```

### 目标的可见性（PUBLIC, PRIVATE, INTERFACE）

可见性决定了属性的传播方式：

| 可见性 | 对目标本身 | 对使用者 | 典型用途 |
|--------|-----------|---------|---------|
| **PRIVATE** | ✓ | ✗ | 内部实现细节 |
| **PUBLIC** | ✓ | ✓ | API 的一部分 |
| **INTERFACE** | ✗ | ✓ | 纯头文件库 |

**示例：**
```cmake
# 库的实现
add_library(mylib
    src/lib.c
    src/internal.c
)

target_include_directories(mylib
    PUBLIC  include/           # 公共 API 头文件
    PRIVATE src/               # 内部实现头文件
)

target_compile_definitions(mylib
    PUBLIC  MYLIB_VERSION=1    # 用户需要知道的宏
    PRIVATE INTERNAL_DEBUG     # 内部调试宏
)

# 使用这个库
add_executable(app main.c)
target_link_libraries(app PRIVATE mylib)
# app 自动获得：
# - mylib 的 PUBLIC 包含目录（include/）
# - mylib 的 PUBLIC 编译定义（MYLIB_VERSION=1）
# 但不会获得：
# - mylib 的 PRIVATE 内容
```

**传播示意图：**
```
executable → PRIVATE → library1 → PUBLIC → library2
                                 ↓
                          INTERFACE → library3

executable 会获得：
- library1 的 PUBLIC 和 INTERFACE 属性
- library2 的所有属性（通过 library1 的 PUBLIC 传播）
- library3 的所有属性（通过 library1 的 INTERFACE 传播）
```

### 案例：多个库的依赖管理

**示例代码见：** `examples/cmake/05-target-properties/`

项目结构：
```
05-target-properties/
├── CMakeLists.txt
├── app/
│   └── main.c
├── network/
│   ├── network.h
│   └── network.c
├── utils/
│   ├── utils.h
│   ├── utils.c
│   └── internal.h
└── common/
    └── common.h
```

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(DependencyManagement)

# ========== common library (header-only) ==========
add_library(common INTERFACE)
target_include_directories(common INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/common
)

# ========== utils library ==========
add_library(utils STATIC
    utils/utils.c
)

target_include_directories(utils
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/utils    # 公共 API
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/utils    # 内部头文件
)

# utils 依赖 common（PUBLIC 因为 utils.h 中包含了 common.h）
target_link_libraries(utils PUBLIC common)

# ========== network library ==========
add_library(network STATIC
    network/network.c
)

target_include_directories(network
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/network
)

# network 内部使用 utils，但不暴露给用户
target_link_libraries(network PRIVATE utils)

# ========== application ==========
add_executable(app
    app/main.c
)

# app 只需要链接 network，会自动获得必要的依赖
target_link_libraries(app PRIVATE network utils)

# 打印依赖关系
message(STATUS "Dependency chain:")
message(STATUS "  app -> network (PRIVATE)")
message(STATUS "  app -> utils (PRIVATE)")
message(STATUS "  network -> utils (PRIVATE)")
message(STATUS "  utils -> common (PUBLIC)")
```

`common/common.h`:
```c
#ifndef COMMON_H
#define COMMON_H

#define VERSION "1.0.0"
#define MAX_BUFFER 1024

#endif
```

`utils/utils.h`:
```c
#ifndef UTILS_H
#define UTILS_H

#include "common.h"  // 公共依赖

void print_version(void);
int string_length(const char* str);

#endif
```

`utils/utils.c`:
```c
#include "utils.h"
#include "internal.h"  // 私有头文件
#include <stdio.h>
#include <string.h>

void print_version(void) {
    printf("Utils version: %s\n", VERSION);
}

int string_length(const char* str) {
    return str ? strlen(str) : 0;
}
```

`utils/internal.h`:
```c
#ifndef INTERNAL_H
#define INTERNAL_H

// 内部调试宏
#define DEBUG_LOG(msg) printf("[DEBUG] %s\n", msg)

#endif
```

`network/network.h`:
```c
#ifndef NETWORK_H
#define NETWORK_H

void network_init(void);
void network_send(const char* data);

#endif
```

`network/network.c`:
```c
#include "network.h"
#include "utils.h"  // 私有依赖
#include <stdio.h>

void network_init(void) {
    print_version();
    printf("Network initialized\n");
}

void network_send(const char* data) {
    printf("Sending %d bytes: %s\n", string_length(data), data);
}
```

`app/main.c`:
```c
#include "network.h"
#include "utils.h"
#include <stdio.h>

int main() {
    network_init();
    network_send("Hello, World!");
    print_version();
    return 0;
}
```

**构建和测试：**
```bash
mkdir build && cd build
cmake ..
make
./app
```

**关键点：**
1. `common` 是 INTERFACE 库（纯头文件）
2. `utils` PUBLIC 依赖 `common`，所以使用 `utils` 的也能访问 `common`
3. `network` PRIVATE 依赖 `utils`，内部使用但不暴露
4. `app` 只需声明直接依赖，间接依赖自动处理

---

## 4.2 查找与使用外部库

### find_package() 的使用

`find_package()` 是 CMake 查找外部库的标准方式。

**基本用法：**
```cmake
# 查找必需的包
find_package(OpenSSL REQUIRED)

# 查找可选的包
find_package(CURL)
if(CURL_FOUND)
    # 使用 CURL
endif()

# 查找特定版本
find_package(Boost 1.70 REQUIRED)

# 查找特定组件
find_package(Boost REQUIRED COMPONENTS filesystem system)

# 查找并指定变量
find_package(ZLIB REQUIRED)
message(STATUS "ZLIB version: ${ZLIB_VERSION}")
message(STATUS "ZLIB include: ${ZLIB_INCLUDE_DIRS}")
message(STATUS "ZLIB libraries: ${ZLIB_LIBRARIES}")
```

### Find<Package>.cmake 模块

CMake 内置了许多 `Find<Package>.cmake` 模块，位于 `/usr/share/cmake-X.Y/Modules/`。

**查看可用模块：**
```bash
ls /usr/share/cmake-*/Modules/Find*.cmake
# FindBoost.cmake
# FindCURL.cmake
# FindOpenSSL.cmake
# FindZLIB.cmake
# ...
```

**自定义 Find 模块：**

`cmake/FindMyLib.cmake`:
```cmake
# 查找头文件
find_path(MYLIB_INCLUDE_DIR
    NAMES mylib.h
    PATHS /usr/local/include /opt/mylib/include
)

# 查找库文件
find_library(MYLIB_LIBRARY
    NAMES mylib
    PATHS /usr/local/lib /opt/mylib/lib
)

# 设置结果变量
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MyLib
    REQUIRED_VARS MYLIB_LIBRARY MYLIB_INCLUDE_DIR
)

if(MYLIB_FOUND)
    # 创建 Imported Target
    add_library(MyLib::MyLib UNKNOWN IMPORTED)
    set_target_properties(MyLib::MyLib PROPERTIES
        IMPORTED_LOCATION "${MYLIB_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${MYLIB_INCLUDE_DIR}"
    )
endif()
```

使用：
```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
find_package(MyLib REQUIRED)
target_link_libraries(myapp PRIVATE MyLib::MyLib)
```

### pkg-config 与 CMake 的集成

许多 Linux 库使用 `pkg-config` 提供信息。

```cmake
# 查找 pkg-config
find_package(PkgConfig REQUIRED)

# 使用 pkg-config 查找库
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)

# 使用找到的库
target_include_directories(myapp PRIVATE ${GTK3_INCLUDE_DIRS})
target_link_libraries(myapp PRIVATE ${GTK3_LIBRARIES})
target_compile_options(myapp PRIVATE ${GTK3_CFLAGS_OTHER})

# 或使用 Imported Target（推荐）
pkg_check_modules(GTK3 REQUIRED IMPORTED_TARGET gtk+-3.0)
target_link_libraries(myapp PRIVATE PkgConfig::GTK3)
```

### 案例：使用 OpenSSL、第三方库

**示例代码见：** `examples/cmake/06-find-package/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(ExternalLibraries)

set(CMAKE_C_STANDARD 11)

# ========== 示例 1: 使用 OpenSSL ==========
find_package(OpenSSL REQUIRED)

if(OpenSSL_FOUND)
    message(STATUS "OpenSSL found:")
    message(STATUS "  Version: ${OPENSSL_VERSION}")
    message(STATUS "  Include: ${OPENSSL_INCLUDE_DIR}")
    message(STATUS "  Libraries: ${OPENSSL_LIBRARIES}")

    add_executable(ssl_demo ssl_demo.c)
    target_link_libraries(ssl_demo PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# ========== 示例 2: 使用 ZLIB ==========
find_package(ZLIB)

if(ZLIB_FOUND)
    message(STATUS "ZLIB found:")
    message(STATUS "  Version: ${ZLIB_VERSION_STRING}")

    add_executable(zlib_demo zlib_demo.c)
    target_link_libraries(zlib_demo PRIVATE ZLIB::ZLIB)
endif()

# ========== 示例 3: 使用 pkg-config ==========
find_package(PkgConfig)

if(PKG_CONFIG_FOUND)
    pkg_check_modules(SQLITE3 IMPORTED_TARGET sqlite3)

    if(SQLITE3_FOUND)
        message(STATUS "SQLite3 found via pkg-config:")
        message(STATUS "  Version: ${SQLITE3_VERSION}")

        add_executable(sqlite_demo sqlite_demo.c)
        target_link_libraries(sqlite_demo PRIVATE PkgConfig::SQLITE3)
    endif()
endif()

# ========== 示例 4: 可选依赖 ==========
option(USE_CURL "Enable CURL support" ON)

if(USE_CURL)
    find_package(CURL)
    if(CURL_FOUND)
        add_executable(curl_demo curl_demo.c)
        target_link_libraries(curl_demo PRIVATE CURL::libcurl)
        target_compile_definitions(curl_demo PRIVATE USE_CURL)
    else()
        message(WARNING "CURL not found, curl_demo will not be built")
    endif()
endif()
```

`ssl_demo.c`:
```c
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <stdio.h>
#include <string.h>

int main() {
    printf("OpenSSL version: %s\n", OpenSSL_version(OPENSSL_VERSION));

    // 计算 SHA256 哈希
    unsigned char hash[EVP_MAX_MD_SIZE];
    unsigned int hash_len;

    const char* data = "Hello, OpenSSL!";
    EVP_MD_CTX* ctx = EVP_MD_CTX_new();
    EVP_DigestInit_ex(ctx, EVP_sha256(), NULL);
    EVP_DigestUpdate(ctx, data, strlen(data));
    EVP_DigestFinal_ex(ctx, hash, &hash_len);
    EVP_MD_CTX_free(ctx);

    printf("SHA256 of '%s':\n", data);
    for(unsigned int i = 0; i < hash_len; i++) {
        printf("%02x", hash[i]);
    }
    printf("\n");

    return 0;
}
```

`zlib_demo.c`:
```c
#include <zlib.h>
#include <stdio.h>
#include <string.h>

int main() {
    printf("zlib version: %s\n", zlibVersion());

    // 压缩数据
    const char* source = "Hello, zlib! This is a test string for compression.";
    uLongf source_len = strlen(source) + 1;
    uLongf compressed_len = compressBound(source_len);
    unsigned char* compressed = malloc(compressed_len);

    if(compress(compressed, &compressed_len, (unsigned char*)source, source_len) == Z_OK) {
        printf("Original size: %lu bytes\n", source_len);
        printf("Compressed size: %lu bytes\n", compressed_len);
        printf("Compression ratio: %.2f%%\n",
               100.0 * (1.0 - (double)compressed_len / source_len));
    }

    free(compressed);
    return 0;
}
```

**构建：**
```bash
mkdir build && cd build

# 检查依赖
cmake .. -DUSE_CURL=ON

# 如果缺少某个库
sudo apt install libssl-dev libz-dev libsqlite3-dev libcurl4-openssl-dev

# 构建
make

# 运行
./ssl_demo
./zlib_demo
```

---

## 4.3 多目录项目组织

### add_subdirectory() 的使用

```cmake
# 添加子目录
add_subdirectory(src)
add_subdirectory(lib)
add_subdirectory(tests)

# 指定构建输出目录
add_subdirectory(external/lib ${CMAKE_BINARY_DIR}/external)
```

### 父子 CMakeLists.txt 的变量传递

**变量作用域：**
- 子目录继承父目录的变量
- 子目录的修改不影响父目录（除非使用 `PARENT_SCOPE`）

**示例：**

父 `CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(ParentProject)

set(GLOBAL_FLAG "from_parent")
message(STATUS "Parent: GLOBAL_FLAG = ${GLOBAL_FLAG}")

add_subdirectory(subdir)

message(STATUS "Parent after subdir: GLOBAL_FLAG = ${GLOBAL_FLAG}")
```

子 `subdir/CMakeLists.txt`:
```cmake
message(STATUS "Child: inherited GLOBAL_FLAG = ${GLOBAL_FLAG}")

set(GLOBAL_FLAG "modified_in_child")
message(STATUS "Child: modified GLOBAL_FLAG = ${GLOBAL_FLAG}")

set(ANOTHER_VAR "value" PARENT_SCOPE)  # 设置父作用域变量
```

输出：
```
-- Parent: GLOBAL_FLAG = from_parent
-- Child: inherited GLOBAL_FLAG = from_parent
-- Child: modified GLOBAL_FLAG = modified_in_child
-- Parent after subdir: GLOBAL_FLAG = from_parent
```

### 项目结构最佳实践

**推荐结构（中大型项目）：**
```
project/
├── CMakeLists.txt              # 顶层
├── cmake/                       # CMake 模块
│   ├── FindXXX.cmake
│   └── CompilerWarnings.cmake
├── include/                     # 公共头文件
│   └── myproject/
│       └── api.h
├── src/                         # 源代码
│   ├── CMakeLists.txt
│   ├── core/
│   │   ├── CMakeLists.txt
│   │   └── *.c
│   └── utils/
│       ├── CMakeLists.txt
│       └── *.c
├── tests/                       # 测试
│   ├── CMakeLists.txt
│   └── *.c
├── examples/                    # 示例
│   ├── CMakeLists.txt
│   └── *.c
├── docs/                        # 文档
├── external/                    # 第三方库
│   └── googletest/
└── README.md
```

### 案例：构建中大型项目结构

**示例代码见：** `examples/cmake/07-multi-directory/`

顶层 `CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(LargeProject VERSION 1.0.0 LANGUAGES C)

# 设置 C 标准
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# 添加 cmake 模块路径
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# 选项
option(BUILD_TESTS "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# 全局设置
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 包含公共头文件目录
include_directories(${CMAKE_SOURCE_DIR}/include)

# 子目录
add_subdirectory(src)

if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# 安装
install(DIRECTORY include/ DESTINATION include)

# 打印配置摘要
message(STATUS "========================================")
message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")
message(STATUS "========================================")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Build tests: ${BUILD_TESTS}")
message(STATUS "Build examples: ${BUILD_EXAMPLES}")
message(STATUS "Build shared libs: ${BUILD_SHARED_LIBS}")
message(STATUS "========================================")
```

`src/CMakeLists.txt`:
```cmake
# 添加子模块
add_subdirectory(core)
add_subdirectory(utils)

# 主库
add_library(${PROJECT_NAME}
    $<TARGET_OBJECTS:core>
    $<TARGET_OBJECTS:utils>
)

target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# 安装
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
```

`src/core/CMakeLists.txt`:
```cmake
add_library(core OBJECT
    engine.c
    config.c
)

target_include_directories(core PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

`src/utils/CMakeLists.txt`:
```cmake
add_library(utils OBJECT
    string_utils.c
    file_utils.c
)
```

`tests/CMakeLists.txt`:
```cmake
# 查找测试框架（可选）
find_package(GTest)

# 测试可执行文件
add_executable(test_core test_core.c)
target_link_libraries(test_core PRIVATE ${PROJECT_NAME})

add_executable(test_utils test_utils.c)
target_link_libraries(test_utils PRIVATE ${PROJECT_NAME})

# 添加测试
add_test(NAME CoreTests COMMAND test_core)
add_test(NAME UtilsTests COMMAND test_utils)
```

`examples/CMakeLists.txt`:
```cmake
# 示例程序
add_executable(example1 example1.c)
target_link_libraries(example1 PRIVATE ${PROJECT_NAME})

add_executable(example2 example2.c)
target_link_libraries(example2 PRIVATE ${PROJECT_NAME})
```

**构建：**
```bash
mkdir build && cd build

# 配置（所有选项）
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_TESTS=ON \
         -DBUILD_EXAMPLES=ON

# 构建
cmake --build .

# 运行测试
ctest

# 运行示例
./bin/example1

# 安装
sudo cmake --install . --prefix /usr/local
```

---

(由于篇幅限制，我将继续在下一个文件中完成 4.4-4.10 的内容)
