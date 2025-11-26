cmake_minimum_required(VERSION 3.15)
project(MultiDirectory VERSION 1.0)

include_directories(${CMAKE_SOURCE_DIR}/include)

add_subdirectory(src)

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
