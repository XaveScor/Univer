#include "main.h"

int main() {
    pNode list = NULL;
    char ch;

    printf("\n\n!!Custom UNIX shell!!\n");
    printHello();
	while (ch = input(&list)) {
        if (ch == EOF)
            break;
        exec(list);
        printHello();
    }
	return 0;
}
