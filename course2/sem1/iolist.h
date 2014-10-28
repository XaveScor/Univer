# pragma once

#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "main.h"

typedef struct Node* pNode;

typedef struct Node{
	char *value;
	pNode next;
} Node;

void clearList(pNode *);
void pushList(char *, pNode *);
void addSymbol(char, char **, size_t *, size_t *);
char *getName(pNode);

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

char *getName(pNode list) {
    pNode lastEl = list;
    while (lastEl->next)
        lastEl = lastEl->next;

    char *ret = (char *)malloc(strlen(lastEl->value) * sizeof(char) + 1);
    strcpy(ret, lastEl->value);
    return ret;
}
