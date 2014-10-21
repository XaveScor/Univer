#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>

#include "iolist.h"

void clearList(pNode *list) {
	pNode next;
	while (*list) {
		next = (*list)->next;
		free((*list)->value);
		free(*list);
		(*list) = next;
	}
}

void pushList(char *str, pNode *list) {
    if (!strlen(str))
        return;

	pNode el = (pNode)malloc(sizeof(Node));
	assert(el);
	el->value = (char *)malloc(sizeof(char) * strlen(str));
	assert(el->value);

	strcpy(el->value, str);

	el->next = (*list);
	(*list) = el;
}

void addSymbol(char ch, char **str, size_t *cur, size_t *len) {
    if (*cur + 1 >= *len) {
        *len = (size_t)(MULTIPLYER * (*len) + 1.0);
        *str = (char *)realloc(*str, sizeof(char) * (*len));
    }
    assert(*str);
    *(*str + (*cur)++) = ch;
}

void printList(pNode list) {
    if (list == NULL)
        return;

    printList(list->next);
    printf("(%s) ", list->value);
}


char input(pNode *list) {
	size_t cur = 0,
           len = 1;
	char ch = EOS, *str = NULL;
	bool state = false;

	clearList(list);
	clearStr(&str);

	while (ch = getchar()) {
        if (state)
            switch(ch) {
                case EOF:
                case DELIMITER:
                case BORDER:
                    state = false;
                    if (ch == BORDER)
                        continue;
                    break;
                default:
                    addSymbol(ch, &str, &cur, &len);
                    continue;
            }

		switch (ch) {
			case BORDER:
			    state = true;
				break;

			default:
				addSymbol(ch, &str, &cur, &len);
				break;

            case DELIMITER:
			case EOF:
			case SEPARATOR:
				str[cur] = EOS;
				pushList(str, list);

				clearStr(&str);
				cur = 0;
				len = 1;
                if (ch == SEPARATOR)
                    continue;
				return ch;
		}
	}
}

void clearStr(char **str) {
    if (*str)
        free(*str);

    *str = (char *)malloc(sizeof(char));
    assert(*str);
    **str = EOS;
}

int main() {
    pNode list = NULL;
    char ch;

	while (ch = input(&list)) {
        printList(list);
        putchar('\n');
        if (ch == EOF)
            break;
	}

    #if defined(_WIN32) && !DEBUG
        system("pause");
    #endif
	return 0;
}
