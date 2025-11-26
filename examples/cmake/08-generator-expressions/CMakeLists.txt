cmake_minimum_required(VERSION 3.15)
project(GeneratorExpressions)

add_executable(myapp main.c)

target_compile_options(myapp PRIVATE
    -Wall
    $<$<CONFIG:Debug>:-g3 -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)

target_compile_definitions(myapp PRIVATE
    VERSION="1.0"
    $<$<CONFIG:Debug>:DEBUG_MODE>
    BUILD_TYPE="$<CONFIG>"
)
