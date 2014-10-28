#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>

#include "iolist.h"
#include "exec.h"

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
				cur = 0, len = 1;
                if (ch == SEPARATOR)
                    continue;
				return ch;
		}
	}
}

void exec(pNode list) {
    if (list == NULL)
        return;

    char *name = getName(list);

    if (!strcmp(name, "cd"))
        return execCD(list);

    if (fork())
        return execParent();

    execChild(list);
}

int main() {
    pNode list = NULL;
    char ch;

	while (ch = input(&list)) {
        if (ch == EOF)
            break;
        exec(list);
    }
	return 0;
}
