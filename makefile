all:	a
	
a:	b
	./mylex<correct1.ptuc
	
b:	c
	gcc -o mylex lex.yy.c myanalyzer.tab.c cgen.c -lfl

c:	d	
	flex mylex.l
d:
	clear all
	bison -d -v -r all myanalyzer.y 
