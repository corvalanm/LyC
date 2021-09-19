%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include "y.tab.h"
%}
%option noyywrap
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
ESPACIO     [ \t]

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
"ELSE"|"else"
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
"*/".*"/*"              {}

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
\".*\"                  {   
                            if(strlen(yytext) < 32){ 
                                int cant = strlen(yytext); 
                                yylval.t_str = (char*)malloc(cant - 1);
                                strncpy(yylval.t_str, yytext+1, cant-2);
                                yylval.t_str[cant-2] = '\0';
                                return STRING_CTE;
                            }
                            return STRING_CTE_ERROR;
                             
                        }
{DIGITO}+                                         {
                                                        if(atoi(yytext) <= 32767 && atoi(yytext) >= 0) {
                                                            yylval.entero = atoi(yytext);
                                                            return NUM_ENTERO;
                                                        }
                                                        
                                                        return ENTERO_ERROR;
                                                        }
({DIGITO}+"."{DIGITO}*)|({DIGITO}*"."{DIGITO}+)   {
                                                        if(atof(yytext) <= +3.4E+38 && atof(yytext) >= 0){
                                                            yylval.real = atof(yytext);
                                                            return NUM_REAL;
                                                        }
                                                        
                                                        return REAL_ERROR;
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
%%


int yyerror(char *s)
{
    printf("\nLinea %d: ERROR %s", yylineno, s);
}