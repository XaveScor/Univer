# pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <assert.h>
#include <sys/wait.h>
#include <sys/types.h>

#define DELIMITER '\n'
#define EOS '\0'
#define SEPARATOR ' '
#define BORDER '"'
#define MULTIPLYER 1.6


typedef struct sNode* pNode;
typedef struct sNode{
	char *value;
	pNode next;
} Node;

char input(pNode *);
void Xexit();

void clearList(pNode *);
void pushList(char *, pNode *);

void addSymbol(char, char **, size_t *, size_t *);
void clearStr(char **);
void printHello();

void exec(pNode);
void execParent();
void execChild(pNode);
void execCD(pNode);
