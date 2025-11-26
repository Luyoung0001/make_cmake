add_library(core OBJECT core/core.c)
add_library(utils OBJECT utils/utils.c)

add_executable(myapp main.c)
target_link_libraries(myapp PRIVATE core utils)
