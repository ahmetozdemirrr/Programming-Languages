all: compile

compile:
	
	yacc -d gpp_interpreter.y
	lex gpp_lexer.l
	cc lex.yy.c y.tab.c -o gpp_interpreter.exe -ll

