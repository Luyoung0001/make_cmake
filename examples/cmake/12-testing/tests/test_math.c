#include <stdio.h>
#include <assert.h>
extern int add(int, int);
int main() {
    assert(add(2, 3) == 5);
    printf("Tests passed\n");
    return 0;
}
