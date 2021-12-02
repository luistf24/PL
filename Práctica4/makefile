
sintactico: main.o y.tab.o
	gcc -o sintactico main.o y.tab.o
	mv sintactico ./bin
	mv y.output ./test/
	rm -f main.o y.tab.o lex.yy.c y.tab.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

main.o:
	gcc -c ./src/main.c

y.tab.c: ./src/as.y lex.yy.c
	bison -v -o y.tab.c ./src/as.y

lex.yy.c: ./src/lex.l
	flex ./src/lex.l

clean:
	rm -f ./bin/sintactico ./test/y.output
todo:
	make clean
	make sintactico

