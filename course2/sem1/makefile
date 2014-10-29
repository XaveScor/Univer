Xshell:		main.o list.o exec.o Xstring.o input.o
			gcc main.o list.o exec.o Xstring.o input.o -o Xshell

main.o:		main.c main.h
			gcc -c main.c

list.o:		list.c main.h
			gcc -c list.c

exec.o:		exec.c main.h
			gcc -c exec.c

Xstring.o:	Xstring.c main.h
			gcc -c Xstring.c

input.o:	input.c main.h
			gcc -c input.c
			
clean:
			rm main.o list.o exec.o Xstring.o input.o

run:	Xshell
		./Xshell


