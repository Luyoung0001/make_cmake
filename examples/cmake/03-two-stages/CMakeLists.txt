cmake_minimum_required(VERSION 3.10)
project(TwoStages)

message(STATUS "========== Configure Stage ==========")
message(STATUS "Detecting compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

add_executable(app main.c)

message(STATUS "========== Generate Stage Next ==========")
