prueba: main.o y.tab.o
	gcc -o prueba main.o y.tab.o
y.tab.o: y.tab.c
	gcc -c y.tab.c
main.o: funcion.c
	gcc -c main.c
y.tab.c: as.y lex.yy.c
	byacc -o y.tab.c as.y
lex.yy.c: lex.l
	flex lex.l
clean:
	rm -f prueba main.o y.tab.o y.tab.c lex.yy.c
todo:
	make limpia
	make prueba

