#include "main.h"

int main() {
    pNode list = NULL;
    char ch;

	while (ch = input(&list)) {
        if (ch == EOF)
            break;
        exec(list);
    }
	return 0;
}
