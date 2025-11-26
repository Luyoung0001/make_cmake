#include <stdio.h>
#include "version.h"
int main() {
    printf("Version: %s\n", VERSION);
    printf("Build time: %s\n", BUILD_TIME);
    return 0;
}
