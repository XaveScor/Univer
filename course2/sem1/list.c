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
	el->value = (char *)malloc(sizeof(char) * strlen(str));
	assert(el->value);

	strcpy(el->value, str);

	el->next = (*list);
	(*list) = el;
}

char *getName(pNode list) {
    pNode lastEl = list;
    while (lastEl->next)
        lastEl = lastEl->next;

    char *ret = (char *)malloc(strlen(lastEl->value) * sizeof(char) + 1);
    strcpy(ret, lastEl->value);
    return ret;
}
