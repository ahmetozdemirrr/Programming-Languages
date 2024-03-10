run1:
	flex -o gpp_lexer.c gpp_lexer.l
	gcc gpp_lexer.c -lfl -o lexer
	./lexer

run2:
	flex -o gpp_lexer.c gpp_lexer.l
	gcc gpp_lexer.c -lfl -o lexer
	./lexer < input.gpp

run3:
	scbl --script gpp_lexer.lisp