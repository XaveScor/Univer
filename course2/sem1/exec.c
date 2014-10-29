#include "main.h"

void exec(pNode list) {
    if (list == NULL)
        return;

    if (!strcmp(list->value, "cd"))
        return execCD(list->next);

    if (fork())
        return execParent();

    execChild(list);
}

void execParent() {
    wait(0);
}

void execChild(pNode list) {
    exit(EXIT_SUCCESS);
}

void execCD(pNode child) {
    if (!child)
        return;

    chdir(child->value);
}
