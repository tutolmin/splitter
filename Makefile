BASE=splitter
EXEC=splitter
LIBS=-lfl -lm -lcrypto 
INCLUDE=-std=gnu99
CC=gcc

DEBUGINFO=-g

# These flags are particularly severe on checking warnings.
# It may be that they are not all appropriate to your environment.
# For instance, not all environments have prototypes available for
# the standard library functions.

# Linux users might need to add -D__linux__ to these in order to
# use strcasecmp instead of strcmpi (cf output.c)

# Mac OS X users might need to add -D__unix__ to CFLAGS
# and use CC=cc or CC=gcc

OPTIMISE=-O3

CFLAGS+=-c -pedantic -Wall -Wshadow -Wformat -Wpointer-arith \
	-Wstrict-prototypes -Wmissing-prototypes -Wwrite-strings \
	-Wsign-compare -Wimplicit-function-declaration $(DEBUGINFO) \
	-I/usr/local/lib/ansi-include -std=gnu99 \
	-D__linux__ \
        $(OPTIMISE)
	 
LEX=flex
BYACC=byacc
$(EXEC)		: y.tab.o lex.yy.o
			$(CC) $(DEBUGINFO) -o $(EXEC) lex.yy.o y.tab.o $(LIBS)
lex.yy.o	: lex.yy.c
			$(CC) $(CFLAGS) -c lex.yy.c
lex.yy.c	: $(BASE).l
			$(LEX) $(BASE).l
y.tab.o		: y.tab.c
			$(CC) $(CFLAGS) -c y.tab.c
y.tab.c		: $(BASE).y
			$(BYACC) -v -d $(BASE).y
clean		:
			rm -f ./lex.yy.c ./y.tab.c ./y.output ./y.tab.h ./*.o ./*.core ./*~ ./*.out

