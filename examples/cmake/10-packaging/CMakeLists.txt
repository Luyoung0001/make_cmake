cmake_minimum_required(VERSION 3.15)
project(Packaging VERSION 1.0)

add_executable(myapp src/main.c)
add_library(mylib SHARED lib/mylib.c)

install(TARGETS myapp DESTINATION bin)
install(TARGETS mylib DESTINATION lib)

set(CPACK_PACKAGE_NAME "mypackage")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "TGZ;DEB")

include(CPack)
