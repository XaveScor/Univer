#include "main.h"

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

void Xexit() {
    printf("!!Custom UNIX shell closed!!\n\n");
    exit(EXIT_SUCCESS);
}
