flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c tb_simbolo.c -o Primera.exe 