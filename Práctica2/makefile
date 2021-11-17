
sintactico: main.o y.tab.o
	gcc -o sintactico main.o y.tab.o

y.tab.o: y.tab.c
	gcc -c y.tab.c

main.o:
	gcc -c main.c

y.tab.c: as.y lex.yy.c
	bison -v -o y.tab.c as.y

lex.yy.c: lex.l
	flex lex.l

clean:
	rm -f sintactico main.o y.tab.o y.tab.c lex.yy.c y.output
todo:
	make clean
	make sintactico

