#include <stdio.h>
int main() {
    printf("Build type: %s\n", BUILD_TYPE);
#ifdef DEBUG_MODE
    printf("Debug mode enabled\n");
#endif
    return 0;
}
