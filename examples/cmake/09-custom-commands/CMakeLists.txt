cmake_minimum_required(VERSION 3.15)
project(CustomCommands VERSION 1.0)

string(TIMESTAMP BUILD_TIME "%Y-%m-%d %H:%M:%S")

configure_file(version.h.in ${CMAKE_BINARY_DIR}/version.h @ONLY)

add_executable(myapp main.c)
target_include_directories(myapp PRIVATE ${CMAKE_BINARY_DIR})
