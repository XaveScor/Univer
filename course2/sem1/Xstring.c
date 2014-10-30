#include "main.h"

void addSymbol(char ch, char **str, size_t *cur, size_t *len) {
    if (*cur + 1 >= *len) {
        *len = (size_t)(MULTIPLYER * (*len) + 1.0);
        *str = (char *)realloc(*str, sizeof(char) * (*len));
    }
    assert(*str);
    *(*str + (*cur)++) = ch;
}

void clearStr(char **str) {
    if (*str)
        free(*str);

    *str = (char *)calloc(1, sizeof(char));
    assert(*str);
}

void printHello() {
    char *cwd = malloc(sizeof(char) * 256);
    getcwd(cwd, 256);
    printf("%s: ", cwd);
}
