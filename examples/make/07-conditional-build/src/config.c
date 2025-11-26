#include <stdio.h>

void print_config() {
#ifdef DEBUG
    printf("Configuration: DEBUG\n");
    printf("  - Extra logging enabled\n");
    printf("  - Assertions enabled\n");
    printf("  - Optimization: O0\n");
#endif

#ifdef RELEASE
    printf("Configuration: RELEASE\n");
    printf("  - Optimization: O2\n");
    printf("  - Debug symbols: stripped\n");
#endif

#ifdef VERBOSE
    printf("Verbose mode: ON\n");
#endif
}
