# Make 和 CMake 教程大纲

## 第一部分：Make 教程（从入门到进阶）

### 1. Make 基础入门

**1.1 Make 简介与环境准备**
- 什么是 Make 及其历史
- Make 的应用场景
- Ubuntu 环境下安装 Make
- 第一个 Makefile 示例

**1.2 Makefile 基本语法**
- 规则（Rule）的结构：目标、依赖、命令
- 变量的定义与使用
- 自动化变量（$@, $<, $^）
- 案例：编译单个 C 文件

**1.3 Make 的工作原理**
- 依赖关系图的构建
- 时间戳检查机制
- 为什么 Make 能实现增量编译
- 案例：演示文件修改时间对编译的影响

### 2. Make 进阶技巧

**2.1 模式规则与隐式规则**
- 通配符的使用（%）
- 内置隐式规则
- 自定义模式规则
- 案例：批量编译多个源文件

**2.2 函数与高级变量**
- 字符串处理函数（subst, patsubst, filter）
- 文件名函数（wildcard, basename, dir）
- 条件判断（ifeq, ifneq）
- 案例：根据不同配置编译不同版本

**2.3 伪目标与特殊目标**
- .PHONY 的作用与使用
- .SUFFIXES, .PRECIOUS 等特殊目标
- 常见伪目标：clean, install, all
- 案例：完整的项目构建流程

**2.4 多目录项目组织**
- 子目录递归编译
- 使用 include 包含其他 Makefile
- 变量的作用域与导出
- 案例：中型项目的 Makefile 结构

**2.5 并行编译与优化**
- make -j 参数的使用
- 依赖关系对并行编译的影响
- 编译性能优化技巧
- 案例：对比串行与并行编译性能

**2.6 调试与常见问题**
- make -n, -d 等调试选项
- 常见错误排查
- Linux 知识穿插：shell 命令、环境变量、文件权限
- 案例：排查实际项目中的 Makefile 问题

---

## 第二部分：CMake 教程（从入门到进阶）

### 3. CMake 基础入门

**3.1 CMake 简介与��势**
- 什么是 CMake
- CMake vs Make 的对比
- 为什么需要 CMake
- Ubuntu 环境下安装 CMake

**3.2 第一个 CMakeLists.txt**
- 最小化的 CMakeLists.txt
- cmake 命令的基本使用
- 构建目录（out-of-source build）的概念
- 案例：用 CMake 编译 Hello World

**3.3 CMake 基本命令**
- project(), add_executable(), add_library()
- set() 变量定义
- message() 信息输出
- 案例：编译可执行文件和静态库

**3.4 CMake 的工作原理**
- CMake 生成 Makefile 的过程
- 配置阶段与生成阶段
- CMakeCache.txt 的作用
- 案例：查看生成的 Makefile 并理解其结构

### 4. CMake 进阶应用

**4.1 目标（Target）与属性**
- target_include_directories()
- target_link_libraries()
- target_compile_options()
- 目标的可见性（PUBLIC, PRIVATE, INTERFACE）
- 案例：多个库的依赖管理

**4.2 查找与使用外部库**
- find_package() 的使用
- Find<Package>.cmake 模块
- pkg-config 与 CMake 的集成
- 案例：使用 OpenSSL、Boost 等第��方库

**4.3 多目录项目组织**
- add_subdirectory() 的使用
- 父子 CMakeLists.txt 的变量传递
- 项目结构最佳实践
- 案例：构建中大型项目结构

**4.4 生成器表达式**
- $<CONFIG:Debug> 等条件表达式
- 根据不同配置设置不同选项
- 案例：Debug 和 Release 版本的不同编译选项

**4.5 自定义命令与目标**
- add_custom_command()
- add_custom_target()
- 集成代码生成、资源处理等
- 案例：自动生成版本头文件

**4.6 安装与打包**
- install() 命令
- 设置安装路径
- CPack 打包工具
- 案例：生成 deb 包或 tar.gz 包

**4.7 交叉编译与工具链**
- CMAKE_TOOLCHAIN_FILE
- 交叉编译的配置
- Linux 知识穿插：系统架构、链接器、动态库
- 案例：为 ARM 平台交叉编译

**4.8 测试与集成**
- enable_testing() 和 add_test()
- CTest 的使用
- 与 CI/CD 集成
- 案例：构建完整的测试框架

**4.9 现代 CMake 最佳实践**
- 目标导向的 CMake（Modern CMake）
- 避免使用全局命令
- 可重用的 CMake 模块
- 案例：编写一个可供其他项目使用的 CMake 库

**4.10 调试与优化**
- CMAKE_VERBOSE_MAKEFILE
- --trace 等调试选项
- 常见问题排查
- 案例：解决实际项目中的 CMake 问题

---

## 附录

**附录 A：Linux 基础知识补充**
- Shell 基本命令
- 环境变量与路径
- 编译器与链接器基础
- 动态库与静态库

**附录 B：实战项目**
- 项目 1：多模块 C 项目（Make）
- 项目 2：跨平台 C++ 项目（CMake）
- 项目 3：混合使用 Make 和 CMake

**附录 C：参考资源**
- 官方文档链接
- 常用命令速查表
- 推荐阅读材料
