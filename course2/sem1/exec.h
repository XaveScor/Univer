# pragma once

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/wait.h>
#include <sys/types.h>

#include "main.h"

void execParent();
void execChild(pNode);
void execCD(pNode);

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
