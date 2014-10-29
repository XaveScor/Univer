#include "main.h"

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
	el->value = (char *)malloc(sizeof(char) * strlen(str) + 1);
	assert(el->value);
	el->next = NULL;

	strcpy(el->value, str);

    if (!(*list)) {
        *list = el;
        return;
    }

    pNode temp = *list;
    while (temp->next) {
        temp = temp->next;
    }
    temp->next = el;
}
