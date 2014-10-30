#include "main.h"

void exec(pNode list) {
    if (list == NULL)
        return;

    if (!strcmp(list->value, "cd"))
        return execCD(list->next);

    if (!strcmp(list->value, "exit"))
        Xexit();

    if (fork())
        return execParent();

    execChild(list);
}

void execParent() {
    wait(0);
}

void execChild(pNode list) {
    char **argv = NULL;

    size_t i = 0;
    pNode temp = list;
    while(temp) {
        ++i;
        temp = temp->next;
    }

    argv = (char **)malloc(sizeof(char *) * (i + 1));
    i = 0;
    temp = list;
    while(temp) {
        argv[i] = (char *)malloc(sizeof(char) * strlen(temp->value) + 1);
        strcpy(argv[i], temp->value);
        temp = temp->next;
        ++i;
    }
    argv[i] = NULL;

    execvp(list->value, argv);
    exit(EXIT_SUCCESS);
}

void execCD(pNode child) {
    if (!child)
        return;

    chdir(child->value);
}
