%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include "y.tab.h"
    #include "tb_simbolo.h"
    
    int yyerror(char *s);
%}
%option noyywrap
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
ESPACIO     [ \t]

SIMBOLOS_VALIDOS (\"|{LETRA}|{DIGITO}|{ESPACIO}|":="|"["|"]"|"("|")"|","|"."|"="|"+"|"-"|"/"|"*"|"<"|">"|"<="|">="|"!="|"==")

%%

    /* DECLARACIONES */
"DIM"|"dim"             {return DIM;}
"AS"|"as"               {return AS;}

    /* ITERACIÓN */
"WHILE"|"while"         {return WHILE;}
"DO"|"do"               {return DO;}
"IN"|"in"               {return IN;}
"ENDWHILE"|"endwhile"   {return ENDWHILE;}

    /* DECISIÓN */
"IF"|"if"               {return IF;}
"ELSE"|"else"           {return ELSE;}
"ENDIF"|"endif"         {return ENDIF;}

    /* LONGITUD, ENTRADA Y SALIDA */
"LONG"|"long"           {return LONG;}
"DISPLAY"|"display"     {return DISPLAY;}
"GET"|"get"             {return GET;}

    /* ASIGNACIÓN y TIPO DE DATO */
":="                    {return ASIG;}
"REAL"|"real"           {return TD_REAL;}
"INTEGER"|"integer"     {return TD_INTEGER;}

    /* COMENTARIO */
"*/"{SIMBOLOS_VALIDOS}*"/*" {}

    /* OPERADOR LÓGICO */
"AND"|"and"             {return AND;}
"OR"|"or"               {return OR;}
"NOT"|"not"             {return NOT;}

    
"["                     {return COR_ABR;}
"]"                     {return COR_CIE;}
"("                     {return PAR_ABR;}
")"                     {return PAR_CIE;}
","                     {return COMA;}

    /* OPERADORES RELACIONALES */
">"                     {return MAYOR;}
">="                    {return MAYOR_IGUAL;}
"<"                     {return MENOR;}
"<="                    {return MENOR_IGUAL;}
"=="                    {return IGUAL;}
"!="                    {return DISTINTO;}

    /* OPERADORES MATEMATICOS*/

"+"                     {return MAS;}
"-"                     {return MENOS;}
"*"                     {return MULT;}
"/"                     {return DIV;}

    /* CONTANTES Y VARIABLES */
\"({LETRA}|{DIGITO}|{ESPACIO})*\" {   
                            if(strlen(yytext) <= 32){ // 30 Caracteres + 2 comillas
                                int cant = strlen(yytext); 
                                yylval.t_str = (char*)malloc(cant - 1);
                                strncpy(yylval.t_str, yytext+1, cant-2);
                                yylval.t_str[cant-2] = '\0';

                                char buff[32];
                                sprintf( buff, "_%s_%d", "texto", get_ultimo());
                                agregar_simbolo(buff, STR_CONST, yylval.t_str);
                                return STRING_CTE;
                            }
                            yyerror("Superaste el limite de 30 caracteres.");exit(1); 
                        }
{DIGITO}+                                         {
                                                        if(atoi(yytext) <= 32767 && atoi(yytext) >= 0) {
                                                            yylval.entero = atoi(yytext);

                                                            char buff[100];
                                                            sprintf( buff, "%s%d", "_", yylval.entero);
                                                            agregar_simbolo(buff, INT_CONST, (void*)&yylval.entero);

                                                            return NUM_ENTERO;
                                                        }
                                                        
                                                        yyerror("El numero ENTERO no es de 16 bits.");exit(1);
                                                        }
({DIGITO}+"."{DIGITO}*)|({DIGITO}*"."{DIGITO}+)   {
                                                        if(atof(yytext) <= +3.4E+38 && atof(yytext) >= 0){
                                                            yylval.real = atof(yytext);

                                                            char buff[100];
                                                            sprintf(buff, "%s%f", "_", yylval.real);
                                                            agregar_simbolo(buff, REAL_CONST, &yylval.real);

                                                            return NUM_REAL;
                                                        }
                                                        yyerror("El numero REAL no es de 32 bits.");exit(1);
                                                    }

{LETRA}({LETRA}|{DIGITO})*                          {
                                                        yylval.t_str = (char*)malloc(strlen(yytext) + 1);
                                                        if(yylval.t_str != NULL){
                                                            strcpy(yylval.t_str, yytext);
                                                            return ID;
                                                        }
                                                        
                                                    }


{ESPACIO}   {}
\n   { }
. {yyerror("Caracter invalido");exit(1);}
%%


int yyerror(char *s)
{
    printf("\nLinea %d: ERROR %s", yylineno, s);
}