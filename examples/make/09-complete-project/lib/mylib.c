#include <stdio.h>
#include "mylib.h"

void mylib_init(void) { printf("Library initialized\n"); }
void mylib_process(void) { printf("Processing...\n"); }
void mylib_cleanup(void) { printf("Cleanup complete\n"); }
