%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "tb_simbolo.h"

    FILE *yyin;
    void yyerror(char *s);
    int yylex();

    typedef struct decl_elem {
        char* name;
        int tipo_dato;
    } t_dec_elem;

    t_dec_elem lista_declaracion [TAM_ARRAY];
    
%}

%union{
  int entero;
  char* t_str;
  float real;
}

%token DIM AS
%token WHILE DO IN ENDWHILE 
%token IF ENDIF ELSE
%token DISPLAY GET LONG 
%token AND OR NOT
%token TD_REAL TD_INTEGER
%token MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL IGUAL DISTINTO
%token COR_ABR COR_CIE PAR_ABR PAR_CIE COMA
%token <entero> NUM_ENTERO
%token <real> NUM_REAL
%token <t_str> ID STRING_CTE
%token ENTERO_ERROR REAL_ERROR STRING_CTE_ERROR

%right ASIG
%left MAS MENOS
%left DIV MULT

%type <entero> lista_id lista_td td

%%
/*Regla n1*/
start: programa {printf("\nRegla 1: COMPILACION EXITOSA");}

/*Regla n2*/
programa: programa instruccion  //{printf("\nRegla 2.1: programa instruccion");}
        | instruccion           //{printf("\nRegla 2.2: instruccion");}

/*Regla n3*/
instruccion: declaracion        //{printf("\nRegla 3.1: instruccion declaracion");}
        | iteracion             //{printf("\nRegla 3.2: instruccion iteracion");}
        | condicional           //{printf("\nRegla 3.3: instruccion condicional");}
        | asignacion            //{printf("\nRegla 3.4: instruccion asignacion");}
        | mostrar               //{printf("\nRegla 3.5: instruccion mostrar");}
        | obtener               //{printf("\nRegla 3.6: instruccion obtener");}
        | longitud              //{printf("\nRegla 3.7: instruccion longitud");}

/*Regla n4*/
declaracion: DIM COR_ABR lista_id COR_CIE AS COR_ABR lista_td COR_CIE   {   printf("\nRegla 4: Declaracion de variables");
                                                                            if($3 == $7){
                                                                                int i=0;

                                                                                while(i < $3){
                                                                                    agregar_simbolo(lista_declaracion[i].name, lista_declaracion[i].tipo_dato,NULL);
                                                                                    free(lista_declaracion[i].name);
                                                                                    i++;
                                                                                }
                                                                            } else {
                                                                                yyerror("Diferencia entre la cantidad de variables y cantidad de tipo de datos.");
                                                                                YYABORT;                                    
                                                                            }
                                                                        }

/*Regla n5*/
lista_id: lista_id COMA ID {    //printf("\nRegla 5.1: lista_id , ID");
                                if(buscar_simbolo($3, VARIABLE_NUM) == -1){     
                                    lista_declaracion[$1].name = (char *) malloc(strlen($3)+1);
                                    strcpy(lista_declaracion[$1].name, $3);
                                    $$ = $1+1;
                                } else {
                                    yyerror("Nombre de variable repetido.");
                                    YYABORT;  
                                }
                            }
        | ID {//printf("\nRegla 5.2 lista_id: ID");
            if(buscar_simbolo($1, VARIABLE_NUM) == -1){
                lista_declaracion[0].name = (char *) malloc(strlen($1)+1);
                strcpy(lista_declaracion[0].name, $1);
                $$ = 1;
            } else {
                yyerror("Nombre de variable repetido.");
                YYABORT;  
            }
            }

/*Regla n6*/
lista_td: lista_td COMA td {//printf("\nRegla 6.1: lista_td COMA td");
                            lista_declaracion[$1].tipo_dato = $3; 
                            $$ = $1+1;
                            }
        | td {//printf("\nRegla 6.2 lista_td: td");
                lista_declaracion[0].tipo_dato = $1; 
                $$ = 1;}

/*Regla n7*/
td: TD_INTEGER  {$$ = INT_VAR;}     //{printf("\nRegla 7.1: Tipo de dato ENTERO");}
  | TD_REAL     {$$ = REAL_VAR;}    //{printf("\nRegla 7.2: Tipo de dato REAL");}

/*Regla n8*/
iteracion: WHILE PAR_ABR condicion PAR_CIE DO programa ENDWHILE {printf("\nRegla 8.1: Ciclo While");}
        | WHILE ID IN PAR_ABR lista_exp PAR_CIE DO programa ENDWHILE {  printf("\nRegla 8.2: Ciclo Especial");
                                                                        if(buscar_simbolo($2, VARIABLE_NUM) == -1){
                                                                            yyerror("Variable desconocida.");YYABORT;
                                                                        };}

/*Regla n9*/
lista_exp: lista_exp COMA expresion //{printf("\nRegla 9.1: lista_exp , expresion");}
        | expresion                 //{printf("\nRegla 9.1: <lista_exp>: expresion");}

/*Regla n10*/
condicional: IF PAR_ABR condicion PAR_CIE programa ENDIF {printf("\nRegla 10.1: IF");}
        | IF PAR_ABR condicion PAR_CIE programa ELSE programa ENDIF {printf("\nRegla 10.1: IF con ELSE");}

/*Regla n11*/
asignacion: ID ASIG expresion { printf("\nRegla 11: Asignacion");
                                if(buscar_simbolo($1, VARIABLE_NUM) == -1){
                                    yyerror("Variable desconocida");YYABORT;
                                };}

/*Regla n12*/
mostrar: DISPLAY factor		{printf("\nRegla 12.1: DISPLAY Valor numerico");}
    | DISPLAY STRING_CTE	{printf("\nRegla 12.2: DISPLAY String constante");
                            char buff[32];
                            sprintf( buff, "_%s_%d", "texto", get_ultimo());
                            agregar_simbolo(buff, STR_CONST, $2);
                            }
    | DISPLAY STRING_CTE_ERROR {yyerror("Superaste el limite de 30 caracteres."); YYABORT;}
    
/*Regla n13*/
obtener: GET ID		{printf("\nRegla 13: GET"); // Entrada por teclado
                    if(buscar_simbolo($2, VARIABLE_NUM) == -1){
                        yyerror("Variable desconocida");
                        YYABORT;
                    };} 

/*Regla n14*/
condicion: cond_s AND cond_s    {printf("\nRegla 14.1 Condicion anidada por AND ");}    
    | cond_s OR cond_s          {printf("\nRegla 14.2 Condicion anidada por OR ");}
    | NOT cond_s                {printf("\nRegla 14.3 Condicion negada ");}
    | cond_s                    {printf("\nRegla 14.4 Condicion simple ");}

/*Regla n15*/
cond_s : factor MAYOR factor
    | factor MAYOR_IGUAL factor
    | factor MENOR factor
    | factor MENOR_IGUAL factor
    | factor IGUAL factor
    | factor DISTINTO factor

/*Regla n16*/
expresion: expresion MAS termino    {printf("\nRegla 16.1: SUMA ");}
        | expresion MENOS termino   {printf("\nRegla 16.2: RESTA ");}
        | termino                   {printf("\nRegla 16.3: termino ");}

/*Regla n17*/
termino: termino MULT factor    {printf("\nRegla 17.1: MULTIPLICACION ");}
        | termino DIV factor    {printf("\nRegla 17.2: DIVISION ");}
        | factor                {printf("\nRegla 17.3: factor ");}

/*Regla n18*/
factor: PAR_ABR expresion PAR_CIE //{printf("\nRegla 18.1: factor -> PAR_ABR expresion PAR_CIE ");}
    | ID {//{printf("\nRegla 18.2: factor -> ID ");}
        if(buscar_simbolo($1, VARIABLE_NUM) == -1){
                        yyerror("Variable desconocida");
                        YYABORT;
        };}
    | NUM_ENTERO {//printf("\nRegla 18.3: factor -> NUM_ENTERO ");
                    char buff[TAM_ARRAY];
                    sprintf( buff, "%s%d", "_", $1 );
                    agregar_simbolo(buff, INT_CONST, (void*)&$1);} 
    | NUM_REAL  {//printf("\nRegla 18.3: factor -> NUM_REAL ");
                    char buff[TAM_ARRAY];
                    sprintf(buff, "%s%f", "_", $1);
                    agregar_simbolo(buff, REAL_CONST, &$1);} 
    | ENTERO_ERROR {yyerror("El numero ENTERO no es de 16 bits.");YYABORT;}
    | REAL_ERROR {yyerror("El numero REAL no es de 32 bits.");YYABORT;}

/*Regla n19*/
longitud: LONG PAR_ABR contar PAR_CIE {printf("\nRegla 19: Longitud de la lista");}

/*Regla n20*/
contar: contar COMA ID {//printf("\nRegla 20.1: contar -> contar COMA ID");
                        if(buscar_simbolo($3, VARIABLE_NUM) == -1){
                            yyerror("\nVariable desconocida");
                            YYABORT;
                        };}
        | ID {//printf("\nRegla 20.2 contar -> ID");
                if(buscar_simbolo($1, VARIABLE_NUM) == -1){
                        yyerror("\nVariable desconocida");
                        YYABORT;
                    };}

%%


int main(int argc,char **argv)
{
    if (argc==1) {
        printf("\nError: falta el nombre del archivo");
        return 1;
    } 
        
    if ((yyin=fopen(argv[1], "rt")) == NULL){
        printf("\nError: Al intentar abrir el archivo archivo");
        return 1;
    }

    yyparse();
    fclose(yyin);

    liberar_tabla();
    return 0;
}



