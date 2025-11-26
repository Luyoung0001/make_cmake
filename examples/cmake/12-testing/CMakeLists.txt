cmake_minimum_required(VERSION 3.15)
project(Testing VERSION 1.0)

enable_testing()

add_library(mathlib STATIC src/math.c)
target_include_directories(mathlib PUBLIC ${CMAKE_SOURCE_DIR}/include)

add_executable(test_math tests/test_math.c)
target_link_libraries(test_math PRIVATE mathlib)
add_test(NAME MathTests COMMAND test_math)
