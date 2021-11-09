flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c tb_simbolo.c arbol.c assembler.c -o Grupo11.exe 
Grupo11.exe prueba.txt
pause

