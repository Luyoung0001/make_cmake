cmake_minimum_required(VERSION 3.15)
project(FindPackage)

find_package(ZLIB)
if(ZLIB_FOUND)
    add_executable(zlib_demo main.c)
    target_link_libraries(zlib_demo PRIVATE ZLIB::ZLIB)
endif()
