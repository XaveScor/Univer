# pragma once

#define DELIMITER '\n'
#define SEPARATOR ' '
#define BORDER '"'
#define MULTIPLYER 1.6

typedef struct Node* pNode;

typedef struct Node{
	char *value;
	pNode next;
} Node;

char input(pNode *); //OK
void clearList(pNode *); //OK
void pushList(char *, pNode *); //OK
void addSymbol(char, char **, size_t *, size_t *);//OK
void printList(pNode); //OK
void clearStr(char **); //OK
void getEl(pNode ,char *, size_t);
