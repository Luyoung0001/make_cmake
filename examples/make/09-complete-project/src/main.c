#include <stdio.h>
#include "mylib.h"

int main() {
    printf("Complete Project Demo\n");
    mylib_init();
    mylib_process();
    mylib_cleanup();
    return 0;
}
