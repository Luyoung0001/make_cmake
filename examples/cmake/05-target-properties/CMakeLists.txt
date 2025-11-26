cmake_minimum_required(VERSION 3.15)
project(TargetProperties)

add_library(common INTERFACE)
target_include_directories(common INTERFACE common)

add_library(utils STATIC utils/utils.c)
target_include_directories(utils PUBLIC utils)
target_link_libraries(utils PUBLIC common)

add_library(network STATIC network/network.c)
target_include_directories(network PUBLIC network)
target_link_libraries(network PRIVATE utils)

add_executable(app app/main.c)
target_link_libraries(app PRIVATE network utils)
