# pragma once

#define DELIMITER '\n'
#define EOS '\0'
#define SEPARATOR ' '
#define BORDER '"'
#define MULTIPLYER 1.6

void clearStr(char **);

void clearStr(char **str) {
    if (*str)
        free(*str);

    *str = (char *)malloc(sizeof(char));
    assert(*str);
    **str = EOS;
}
