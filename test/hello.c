// musl-gcc -static -nostartfiles -o hello hello.c

#include <unistd.h>

void _start(void) {
    char *str = "Hello, World !\n";
    write(STDOUT_FILENO, str, 15);
    _exit(0);
}
