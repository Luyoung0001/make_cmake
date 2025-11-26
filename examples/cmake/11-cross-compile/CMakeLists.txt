cmake_minimum_required(VERSION 3.15)
project(CrossCompile VERSION 1.0)

message(STATUS "System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "Compiler: ${CMAKE_C_COMPILER}")

add_executable(cross_demo main.c)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    target_compile_definitions(cross_demo PRIVATE ARM_PLATFORM)
endif()
