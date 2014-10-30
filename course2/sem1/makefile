Xshell:		main.o list.o exec.o Xstring.o input.o
			gcc main.o list.o exec.o Xstring.o input.o -o Xshell -O0 -std=c99

main.o:		main.c main.h
			gcc -c main.c -std=c99

list.o:		list.c main.h
			gcc -c list.c -std=c99

exec.o:		exec.c main.h
			gcc -c exec.c -std=c99

Xstring.o:	Xstring.c main.h
			gcc -c Xstring.c -std=c99

input.o:	input.c main.h
			gcc -c input.c -std=c99
			
clean:
			rm main.o list.o exec.o Xstring.o input.o

run:	Xshell
		./Xshell


