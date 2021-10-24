flex Lexico.l
bison -dyv Sintactico.y
gcc -std=c99 lex.yy.c y.tab.c tb_simbolo.c arbol.c -o Segunda.exe 