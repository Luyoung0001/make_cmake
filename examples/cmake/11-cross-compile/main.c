#include <stdio.h>
int main() {
    printf("Cross-compile demo\n");
#ifdef ARM_PLATFORM
    printf("Running on ARM\n");
#endif
    return 0;
}
