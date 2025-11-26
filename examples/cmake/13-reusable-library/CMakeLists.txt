cmake_minimum_required(VERSION 3.15)
project(ReusableLibrary VERSION 1.0)

add_library(mylib STATIC src/mylib.c)
target_include_directories(mylib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

install(TARGETS mylib EXPORT mylibTargets
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/ DESTINATION include)

install(EXPORT mylibTargets
    FILE mylibTargets.cmake
    NAMESPACE mylib::
    DESTINATION lib/cmake/mylib
)
