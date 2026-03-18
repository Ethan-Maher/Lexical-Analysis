all: scanner cmos

scanner: lex.yy.c
	gcc -w -o scanner lex.yy.c

lex.yy.c: cmos.l
	flex cmos.l

cmos: cmos.cpp
	g++ -std=c++11 -w -o cmos cmos.cpp

clean:
	rm -f scanner cmos lex.yy.c scanner_out.txt tokens.txt PlagarismReport.txt