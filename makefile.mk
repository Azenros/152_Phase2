# Makefile

OBJS    = bison.o lex.o main.o

CC      = g++
CFLAGS  = -g -Wall -ansi -pedantic

calc:           $(OBJS)
                $(CC) $(CFLAGS) $(OBJS) -o calc -lfl

lex.o:          lex.c
                $(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:          mini_l.lex
                flex mini_l.lex
                cp lex.yy.c lex.c

bison.o:        bison.c
                $(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:        mini_l.y
                bison -d -v mini_l.y
                cp mini_l.tab.c bison.c
                cmp -s mini_l.tab.h tok.h || cp mini_l.tab.h tok.h

main.o:         main.cc
                $(CC) $(CFLAGS) -c main.cc -o main.o

lex.o yac.o main.o      : heading.h
lex.o main.o            : tok.h

clean:
        rm -f *.o *~ lex.c lex.yy.c bison.c tok.h mini_l.tab.c mini_l.tab.h mini_l.output mini_l