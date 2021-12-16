
semantico: main.o y.tab.o TS.o
	gcc -o semantico main.o y.tab.o TS.o
	rm -f main.o y.tab.o TS.o lex.yy.c y.tab.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

TS.o: TS.c
	gcc -c TS.c

main.o:
	gcc -c main.c

y.tab.c: as.y lex.yy.c
	bison -v -o y.tab.c as.y

lex.yy.c: lex.l
	flex lex.l

clean:
	rm -f semantico y.output
todo:
	make clean
	make semantico