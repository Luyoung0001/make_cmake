
## 4.4 生成器表达式

生成器表达式（Generator Expressions）是在构建系统生成阶段求值的表达式，提供强大的条件配置能力。

### 基本语法

```cmake
$<条件:真值>
$<条件:真值:假值>
$<$<条件>:值>
```

### 配置相关表达式

```cmake
# 根据构建类型设置不同选项
target_compile_options(myapp PRIVATE
    $<$<CONFIG:Debug>:-g -O0 -DDEBUG>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
    $<$<CONFIG:RelWithDebInfo>:-O2 -g>
)

# 等价于：
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(myapp PRIVATE -g -O0 -DDEBUG)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(myapp PRIVATE -O3 -DNDEBUG)
endif()
```

### 编译器相关表达式

```cmake
# 不同编译器的选项
target_compile_options(myapp PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra>
    $<$<CXX_COMPILER_ID:Clang>:-Weverything>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

# 编译器版本
target_compile_features(myapp PRIVATE
    $<$<COMPILE_FEATURES:cxx_std_17>:cxx_std_17>
)
```

### 平台相关表达式

```cmake
# 不同平台的库
target_link_libraries(myapp PRIVATE
    $<$<PLATFORM_ID:Linux>:pthread>
    $<$<PLATFORM_ID:Windows>:ws2_32>
)

# 布尔操作
target_compile_definitions(myapp PRIVATE
    $<$<OR:$<PLATFORM_ID:Linux>,$<PLATFORM_ID:Darwin>>:UNIX_LIKE>
)

# 逻辑操作符：AND, OR, NOT
$<$<AND:$<CONFIG:Debug>,$<PLATFORM_ID:Linux>>:-DDEBUG_LINUX>
```

### 目标相关表达式

```cmake
# 目标属性
target_include_directories(myapp PRIVATE
    $<TARGET_PROPERTY:mylib,INTERFACE_INCLUDE_DIRECTORIES>
)

# 目标文件
add_custom_command(
    OUTPUT processed_$<TARGET_FILE_NAME:myapp>
    COMMAND process $<TARGET_FILE:myapp>
    DEPENDS myapp
)

# 目标存在性
$<TARGET_EXISTS:optional_target>
```

### 字符串操作

```cmake
# 大小写转换
$<UPPER_CASE:${VAR}>
$<LOWER_CASE:${VAR}>

# 连接列表
$<JOIN:${LIST},;>

# 条件输出
$<$<CONFIG:Debug>:debug_info,$<0:>>  # Debug 时输出 debug_info，否则为空
```

### 案例：Debug 和 Release 版本的不同编译选项

**示例代码见：** `examples/cmake/08-generator-expressions/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(GeneratorExpressions)

set(CMAKE_C_STANDARD 11)

# 创建可执行文件
add_executable(myapp main.c utils.c)

# 使用生成器表达式设置编译选项
target_compile_options(myapp PRIVATE
    # 所有配置的通用选项
    -Wall

    # Debug 配置
    $<$<CONFIG:Debug>:
        -g3                 # 最大调试信息
        -O0                 # 无优化
        -fno-omit-frame-pointer
        -fsanitize=address  # 地址消毒器
    >

    # Release 配置
    $<$<CONFIG:Release>:
        -O3                 # 最高优化
        -DNDEBUG           # 禁用断言
        -flto              # 链接时优化
    >

    # RelWithDebInfo 配置
    $<$<CONFIG:RelWithDebInfo>:
        -O2
        -g
    >

    # MinSizeRel 配置
    $<$<CONFIG:MinSizeRel>:
        -Os                 # 优化大小
        -DNDEBUG
    >
)

# 不同配置的编译定义
target_compile_definitions(myapp PRIVATE
    VERSION="1.0"
    $<$<CONFIG:Debug>:DEBUG_MODE VERBOSE_LOGGING>
    $<$<CONFIG:Release>:RELEASE_MODE>
    BUILD_TYPE="$<CONFIG>"
)

# 不同编译器的选项
target_compile_options(myapp PRIVATE
    $<$<C_COMPILER_ID:GNU>:-fstack-protector-strong>
    $<$<C_COMPILER_ID:Clang>:-fstack-protector-all>
)

# 链接选项
target_link_options(myapp PRIVATE
    $<$<CONFIG:Debug>:-fsanitize=address>
)

# 打印生成的配置（仅作演示，实际不会在配置时求值）
message(STATUS "Compiler: ${CMAKE_C_COMPILER_ID}")
message(STATUS "Build types: Debug, Release, RelWithDebInfo, MinSizeRel")
```

`main.c`:
```c
#include <stdio.h>

extern void utils_info(void);

int main() {
    printf("Application version: %s\n", VERSION);
    printf("Build type: %s\n", BUILD_TYPE);

#ifdef DEBUG_MODE
    printf("Running in DEBUG mode\n");
    printf("Verbose logging enabled\n");
#endif

#ifdef RELEASE_MODE
    printf("Running in RELEASE mode\n");
#endif

    utils_info();
    return 0;
}
```

`utils.c`:
```c
#include <stdio.h>

void utils_info(void) {
#ifdef DEBUG_MODE
    printf("Utils: Debug build with extra checks\n");
#else
    printf("Utils: Optimized build\n");
#endif
}
```

**构建不同配置：**
```bash
# Debug 版本
mkdir build-debug && cd build-debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
make VERBOSE=1  # 查看实际编译命令
./myapp

# Release 版本
mkdir build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
make VERBOSE=1
./myapp

# 比较二进制大小
ls -lh */myapp
strip build-release/myapp
ls -lh build-release/myapp
```

---

## 4.5 自定义命令与目标

### add_custom_command()

用于在构建过程中执行自定义命令。

**生成文件：**
```cmake
# 在构建时生成文件
add_custom_command(
    OUTPUT generated.c
    COMMAND python ${CMAKE_SOURCE_DIR}/scripts/generate.py > generated.c
    DEPENDS ${CMAKE_SOURCE_DIR}/scripts/generate.py
    COMMENT "Generating generated.c"
)

add_executable(myapp main.c generated.c)
```

**后处理构建产物：**
```cmake
add_custom_command(
    TARGET myapp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:myapp> ${CMAKE_SOURCE_DIR}/bin/
    COMMENT "Copying myapp to bin directory"
)
```

**前处理：**
```cmake
add_custom_command(
    TARGET myapp PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Building myapp..."
)

add_custom_command(
    TARGET myapp PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E echo "Linking myapp..."
)
```

### add_custom_target()

创建一个始终被认为是过期的目标。

```cmake
# 格式化代码
add_custom_target(format
    COMMAND clang-format -i ${CMAKE_SOURCE_DIR}/src/*.c
    COMMENT "Formatting source code"
)

# 生成文档
add_custom_target(docs
    COMMAND doxygen ${CMAKE_SOURCE_DIR}/Doxyfile
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Generating documentation"
)

# 运行程序
add_custom_target(run
    COMMAND myapp
    DEPENDS myapp
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running myapp"
)

# 清理额外文件
add_custom_target(distclean
    COMMAND ${CMAKE_BUILD_TOOL} clean
    COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
    COMMAND ${CMAKE_COMMAND} -E remove CMakeCache.txt
)
```

### 案例：自动生成版本头文件

**示例代码见：** `examples/cmake/09-custom-commands/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(AutoVersion VERSION 1.2.3)

# 获取 Git 信息
find_package(Git)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
        OUTPUT_VARIABLE GIT_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
else()
    set(GIT_COMMIT_HASH "unknown")
    set(GIT_TAG "unknown")
endif()

# 获取构建时间
string(TIMESTAMP BUILD_TIMESTAMP "%Y-%m-%d %H:%M:%S")

# 配置版本头文件
configure_file(
    ${CMAKE_SOURCE_DIR}/version.h.in
    ${CMAKE_BINARY_DIR}/version.h
    @ONLY
)

# 自定义命令：生成详细版本信息
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/build_info.c
    COMMAND ${CMAKE_COMMAND}
        -DPROJECT_NAME=${PROJECT_NAME}
        -DPROJECT_VERSION=${PROJECT_VERSION}
        -DGIT_COMMIT_HASH=${GIT_COMMIT_HASH}
        -DBUILD_TIMESTAMP="${BUILD_TIMESTAMP}"
        -DINPUT_FILE=${CMAKE_SOURCE_DIR}/build_info.c.in
        -DOUTPUT_FILE=${CMAKE_BINARY_DIR}/build_info.c
        -P ${CMAKE_SOURCE_DIR}/cmake/GenerateBuildInfo.cmake
    DEPENDS ${CMAKE_SOURCE_DIR}/build_info.c.in
    COMMENT "Generating build_info.c"
    VERBATIM
)

# 创建可执行文件
add_executable(myapp
    main.c
    ${CMAKE_BINARY_DIR}/build_info.c  # 生成的文件
)

# 添加包含目录
target_include_directories(myapp PRIVATE ${CMAKE_BINARY_DIR})

# 每次构建都更新版本信息
add_custom_target(update_version ALL
    COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${CMAKE_BINARY_DIR}/build_info.c
    COMMENT "Updating version information"
)

add_dependencies(myapp update_version)

# 安装后脚本
install(TARGETS myapp DESTINATION bin)
install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E echo 'Installation complete')")
```

`version.h.in`:
```c
#ifndef VERSION_H
#define VERSION_H

#define PROJECT_NAME "@PROJECT_NAME@"
#define PROJECT_VERSION "@PROJECT_VERSION@"
#define PROJECT_VERSION_MAJOR @PROJECT_VERSION_MAJOR@
#define PROJECT_VERSION_MINOR @PROJECT_VERSION_MINOR@
#define PROJECT_VERSION_PATCH @PROJECT_VERSION_PATCH@

#define GIT_COMMIT_HASH "@GIT_COMMIT_HASH@"
#define GIT_TAG "@GIT_TAG@"
#define BUILD_TIMESTAMP "@BUILD_TIMESTAMP@"

#endif
```

`build_info.c.in`:
```c
#include <stdio.h>

const char* get_build_info(void) {
    static char buffer[256];
    snprintf(buffer, sizeof(buffer),
        "Project: @PROJECT_NAME@\n"
        "Version: @PROJECT_VERSION@\n"
        "Git Hash: @GIT_COMMIT_HASH@\n"
        "Build Time: @BUILD_TIMESTAMP@"
    );
    return buffer;
}
```

`cmake/GenerateBuildInfo.cmake`:
```cmake
# 从模板生成文件
configure_file(${INPUT_FILE} ${OUTPUT_FILE} @ONLY)
```

`main.c`:
```c
#include <stdio.h>
#include "version.h"

extern const char* get_build_info(void);

int main() {
    printf("========================================\n");
    printf("Application: %s\n", PROJECT_NAME);
    printf("Version: %s\n", PROJECT_VERSION);
    printf("Git Commit: %s\n", GIT_COMMIT_HASH);
    printf("Build Time: %s\n", BUILD_TIMESTAMP);
    printf("========================================\n\n");

    printf("%s\n", get_build_info());

    return 0;
}
```

**构建：**
```bash
mkdir build && cd build
cmake ..
make
./myapp
```

输出：
```
========================================
Application: AutoVersion
Version: 1.2.3
Git Commit: a1b2c3d
Build Time: 2024-01-15 14:30:00
========================================

Project: AutoVersion
Version: 1.2.3
Git Hash: a1b2c3d
Build Time: 2024-01-15 14:30:00
```

---

## 4.6 安装与打包

### install() 命令

```cmake
# 安装可执行文件
install(TARGETS myapp
    RUNTIME DESTINATION bin
)

# 安装库
install(TARGETS mylib
    LIBRARY DESTINATION lib       # .so (Linux)
    ARCHIVE DESTINATION lib       # .a
    RUNTIME DESTINATION bin       # .dll (Windows)
)

# 安装头文件
install(FILES
    include/mylib.h
    include/types.h
    DESTINATION include/mylib
)

# 安装目录
install(DIRECTORY include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# 安装配置文件
install(FILES config/myapp.conf
    DESTINATION etc/myapp
)

# 执行安装脚本
install(SCRIPT ${CMAKE_SOURCE_DIR}/cmake/post_install.cmake)

# 安装导出的目标（供其他项目使用）
install(TARGETS mylib
    EXPORT mylibTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
)

install(EXPORT mylibTargets
    FILE mylibTargets.cmake
    NAMESPACE mylib::
    DESTINATION lib/cmake/mylib
)
```

### 设置安装路径

```cmake
# 默认安装路径
# Linux: /usr/local
# Windows: C:/Program Files/${PROJECT_NAME}

# 修改安装路径
cmake -DCMAKE_INSTALL_PREFIX=/opt/myapp ..

# 在 CMakeLists.txt 中设置
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "/opt/myapp" CACHE PATH "Install path" FORCE)
endif()

# DESTDIR：临时安装目录（打包时常用）
make install DESTDIR=/tmp/package
```

### CPack 打包工具

```cmake
# 基本设置
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "My awesome application")
set(CPACK_PACKAGE_VENDOR "MyCompany")
set(CPACK_PACKAGE_CONTACT "user@example.com")

# 选择生成器
set(CPACK_GENERATOR "TGZ;DEB;RPM")

# DEB 包设置
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27)")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")

# RPM 包设置
set(CPACK_RPM_PACKAGE_LICENSE "MIT")
set(CPACK_RPM_PACKAGE_GROUP "Applications/System")

# 包含 CPack
include(CPack)
```

使用：
```bash
cmake ..
make package         # 生成所有配置的包
make package_source  # 生成源代码包

# 或使用 cpack
cpack -G TGZ         # 生成 tar.gz
cpack -G DEB         # 生成 .deb
cpack -G RPM         # 生成 .rpm
```

### 案例：生成 deb 包或 tar.gz 包

**示例代码见：** `examples/cmake/10-packaging/`

`CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyPackage VERSION 1.0.0)

set(CMAKE_C_STANDARD 11)

# 创建应用程序
add_executable(myapp
    src/main.c
    src/utils.c
)

# 创建库
add_library(mylib SHARED
    lib/mylib.c
)

target_include_directories(mylib PUBLIC include)
target_link_libraries(myapp PRIVATE mylib)

# ========== 安装规则 ==========
# 安装可执行文件
install(TARGETS myapp
    RUNTIME DESTINATION bin
)

# 安装库
install(TARGETS mylib
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# 安装头文件
install(DIRECTORY include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# 安装配置文件
install(FILES config/myapp.conf
    DESTINATION etc/myapp
)

# 安装文档
install(FILES
    README.md
    LICENSE
    DESTINATION share/doc/myapp
)

# 安装 man 手册
install(FILES docs/myapp.1
    DESTINATION share/man/man1
)

# ========== CPack 配置 ==========
# 基本信息
set(CPACK_PACKAGE_NAME "mypackage")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An example application for packaging")
set(CPACK_PACKAGE_DESCRIPTION "This is a detailed description of my application.\nIt can span multiple lines.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://example.com/mypackage")
set(CPACK_PACKAGE_CONTACT "user@example.com")
set(CPACK_PACKAGE_VENDOR "Example Company")

# 文件
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.md")

# ========== DEB 包配置 ==========
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "User <user@example.com>")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27)")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "")
set(CPACK_DEBIAN_PACKAGE_SUGGESTS "")

# DEB 包控制脚本
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_SOURCE_DIR}/debian/postinst"
    "${CMAKE_SOURCE_DIR}/debian/prerm"
)

# ========== RPM 包配置 ==========
set(CPACK_RPM_PACKAGE_LICENSE "MIT")
set(CPACK_RPM_PACKAGE_GROUP "Applications/System")
set(CPACK_RPM_PACKAGE_REQUIRES "glibc >= 2.27")

# RPM 包脚本
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/rpm/postinstall.sh")
set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/rpm/preuninstall.sh")

# ========== 归档包配置 ==========
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)

# ========== 生成器选择 ==========
# 可用生成器：TGZ, ZIP, DEB, RPM, NSIS, etc.
set(CPACK_GENERATOR "TGZ;DEB")

# 源代码包生成器
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_IGNORE_FILES
    /.git
    /build
    /.vscode
    /*.user
    /\\..*
)

# 包含 CPack
include(CPack)
```

`debian/postinst`:
```bash
#!/bin/bash
set -e

# 后安装脚本
echo "Thank you for installing mypackage!"
echo "Configuration file: /etc/myapp/myapp.conf"

# 创建符号链接
if [ ! -e /usr/local/bin/myapp ]; then
    ln -s /usr/bin/myapp /usr/local/bin/myapp
fi

exit 0
```

`debian/prerm`:
```bash
#!/bin/bash
set -e

# 卸载前脚本
echo "Removing mypackage..."

# 删除符号链接
if [ -L /usr/local/bin/myapp ]; then
    rm /usr/local/bin/myapp
fi

exit 0
```

**打包流程：**
```bash
# 1. 配置
mkdir build && cd build
cmake ..

# 2. 构建
make

# 3. 生成包
make package
# 或
cpack

# 输出：
# mypackage-1.0.0-Linux.tar.gz
# mypackage-1.0.0-Linux.deb

# 4. 测试安装 DEB 包
sudo dpkg -i mypackage-1.0.0-Linux.deb
myapp --version

# 5. 测试卸载
sudo dpkg -r mypackage

# 6. 生成源代码包
make package_source
# mypackage-1.0.0-Source.tar.gz

# 7. 检查包内容
dpkg -c mypackage-1.0.0-Linux.deb
tar -tzf mypackage-1.0.0-Linux.tar.gz
```

---

## 小结（第一部分）

在这部分中，我们学习了：
1. **目标属性**：Modern CMake 的目标导向设计
2. **外部库**：使用 `find_package()` 查找和使用第三方库
3. **多目录项目**：使用 `add_subdirectory()` 组织大型项目
4. **生成器表达式**：配置时的条件逻辑
5. **自定义命令**：集成代码生成等自定义步骤
6. **安装打包**：使用 `install()` 和 CPack 打包分发

(继续 4.7-4.10 见下一部分)
