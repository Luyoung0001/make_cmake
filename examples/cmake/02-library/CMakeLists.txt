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

# 为库设置包含目录
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
