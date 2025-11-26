#include <stdio.h>
#include "config.h"

int main() {
    printf("Application starting...\n\n");

    print_config();

#ifdef DEBUG
    printf("\n[DEBUG] Debug mode enabled\n");
    printf("[DEBUG] Extra logging available\n");
#endif

#ifdef VERSION
    printf("\nVersion: %s\n", VERSION);
#endif

    printf("\nApplication running successfully\n");
    return 0;
}
