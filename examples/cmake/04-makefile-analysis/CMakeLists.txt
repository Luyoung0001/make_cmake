cmake_minimum_required(VERSION 3.10)
project(MakefileAnalysis)

set(CMAKE_VERBOSE_MAKEFILE ON)

add_executable(app main.c utils.c)
