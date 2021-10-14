CXX = g++ -w -std=c++11
INC=-I tabla.h

all: pract2

lex.yy.c: lex.l
	@flex lex.l

pract2:	lex.yy.c
	@$(CXX) $(INC) $^ -o $@ -lfl

clean: 
	rm lex.yy.c pract2
