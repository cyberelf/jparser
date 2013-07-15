CC=      gcc
LEX=     flex
YACC=    bison

PROG=    jparse

CFLAGS=    
LEXFLAGS= -ojunos.lex.c
YACCFLAGS= -d

all: clean jparse

clean: 
	rm -f *.h *.c *.o *.out ${PROG}

jparse:
	${YACC} ${YACCFLAGS} junos.y
	${LEX} ${LEXFLAGS} junos.l
	${CC} ${CFLAGS} *.c -o ${PROG}

install: all
	@cp jparse /homes/darren/bin/