%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "tb_simbolo.h"
    #include "arbol.h"

    FILE *yyin;
    void yyerror(char *s);
    int yylex();

    typedef struct decl_elem {
        char* name;
        int tipo_dato;
    } t_dec_elem;

    t_dec_elem lista_declaracion [TAM_ARRAY];
    
    // PUNTEROS PARA LOS NO TERMINALES
    t_nodo* start_ptr;
    t_nodo* programa_ptr;
    t_nodo* sentencia_ptr;
    t_nodo* declaracion_ptr;
    t_nodo* lista_id_ptr;
    t_nodo* lista_td_ptr;
    t_nodo* td_ptr;
    t_nodo* iteracion_ptr;
    t_nodo* while_esp_ptr;
    t_nodo* lista_exp_ptr;
    t_nodo* if_condicional_ptr;
    t_nodo* asignacion_ptr;
    t_nodo* mostrar_ptr;
    t_nodo* obtener_ptr;
    t_nodo* condicion_ptr;
    t_nodo* cond_s_ptr;
    t_nodo* expresion_ptr;
    t_nodo* termino_ptr;
    t_nodo* factor_ptr;
    t_nodo* longitud_ptr;
    t_nodo* contar_ptr;

    t_nodo *aux_factor_ptr; 
    t_nodo *aux_if_ptr;
    t_nodo *aux_cond_s_ptr;
    t_nodo *temp_lista_expr;

    // VARIABLES PARA CODIGO INTERMEDIO
    int _coincidencia_while_esp;
    int _longitud_total;
    char _id_while_especial[40];
    char _aux_str[100];

    t_nodo* pila_cond[100];
    int pila_cond_tope = 0;
    t_nodo* pila_programa[100];
    int pila_programa_tope = 0;
    
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

%right ASIG
%left MAS MENOS
%left DIV MULT

%type <entero> lista_id lista_td td

%%
/*Regla n1*/
start: programa {
        printf("\nRegla 1: COMPILACION EXITOSA");
        start_ptr = programa_ptr;
    }

/*Regla n2*/
programa: programa sentencia  {
        printf("\nRegla 2.1: programa sentencia");
        programa_ptr = crearNodo("BLOQUE", pila_programa[--pila_programa_tope], sentencia_ptr);
        pila_programa[pila_programa_tope++] = programa_ptr;
    }
    | sentencia {
        printf("\nRegla 2.2: sentencia");
        programa_ptr = sentencia_ptr;
        pila_programa[pila_programa_tope++] = programa_ptr;
    }

/*Regla n3*/
sentencia: declaracion          {
        printf("\nRegla 3.1: sentencia declaracion");
        sentencia_ptr = declaracion_ptr;
    }
    | iteracion {
        printf("\nRegla 3.2: sentencia iteracion");
        sentencia_ptr = iteracion_ptr;
    }
    | if_condicional {
        printf("\nRegla 3.3: sentencia if_condicional");
        sentencia_ptr = if_condicional_ptr;
    }
    | asignacion {
        printf("\nRegla 3.4: sentencia asignacion");
        sentencia_ptr = asignacion_ptr;
    }
    | mostrar {
        printf("\nRegla 3.5: sentencia mostrar");
        sentencia_ptr = mostrar_ptr;
    }
    | obtener {
        printf("\nRegla 3.6: sentencia obtener");
        sentencia_ptr = obtener_ptr;
    }
    | longitud {
        printf("\nRegla 3.7: sentencia longitud");
        sentencia_ptr = longitud_ptr;
    }

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
                                                                            declaracion_ptr = crearHoja("DECLARACION");
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
iteracion: WHILE PAR_ABR condicion PAR_CIE DO programa ENDWHILE {
        printf("\nRegla 8.1: Ciclo While");
        iteracion_ptr = crearNodo("WHILE", pila_cond[--pila_cond_tope], pila_programa[--pila_programa_tope]);
    }
    | WHILE ID {strcpy(_id_while_especial, $2);} IN PAR_ABR lista_exp PAR_CIE DO programa ENDWHILE {  
        printf("\nRegla 8.2: Ciclo Especial");
        if(buscar_simbolo($2, VARIABLE_NUM) == -1){yyerror("Variable desconocida.");YYABORT;};
        
        while_esp_ptr = crearNodo("WHILE_ESP", crearNodo("COND_W_ESP", lista_exp_ptr, crearNodo("==", crearHoja("1"), crearHoja("@ejec_while_esp"))), pila_programa[--pila_programa_tope] );
    }

/*Regla n9*/
lista_exp: lista_exp COMA expresion {
        //printf("\nRegla 9.1: lista_exp -> lista_exp , expresion");
        // Se crea 1 if por cada expresion
        // Si la expresion es igual al ID del while le asigna 1 a @ejec_while_esp.
        temp_lista_expr = crearNodo("IF", crearNodo("==", crearHoja(_id_while_especial), expresion_ptr), crearNodo(":=", crearHoja("@ejec_while_esp"), crearHoja("1")));
        lista_exp_ptr = crearNodo("LISTA_EXP", lista_exp_ptr, temp_lista_expr);
    }
    | expresion {
        //printf("\nRegla 9.1: lista_exp -> expresion");
        // Inicializa la variable @ejec_while_esp = 0 y si la expresion es igual al ID del while le asigna 1 a @ejec_while_esp
        temp_lista_expr = crearNodo("IF", crearNodo("==", crearHoja(_id_while_especial), expresion_ptr), crearNodo(":=", crearHoja("@ejec_while_esp"), crearHoja("1")));
        temp_lista_expr = crearNodo("BLOQUE", crearNodo(":=", crearHoja("@ejec_while_esp"), crearHoja("0")), temp_lista_expr);
        lista_exp_ptr = temp_lista_expr;
    }

/*Regla n10*/
if_condicional: IF PAR_ABR condicion PAR_CIE programa ENDIF {
        printf("\nRegla 10.1: IF");
        if_condicional_ptr = crearNodo("IF", pila_cond[--pila_cond_tope], pila_programa[--pila_programa_tope]);
    }
    | IF PAR_ABR condicion PAR_CIE programa ELSE programa ENDIF {
        printf("\nRegla 10.1: IF con ELSE");
        if_condicional_ptr = crearNodo("IF", pila_cond[--pila_cond_tope], crearNodo("CUERPO", pila_programa[--pila_programa_tope], pila_programa[--pila_programa_tope]));
    }

/*Regla n11*/
asignacion: ID ASIG expresion { 
        printf("\nRegla 11: Asignacion");
        if(buscar_simbolo($1, VARIABLE_NUM) == -1){yyerror("Variable desconocida");YYABORT;};
        asignacion_ptr = crearNodo(":=", crearHoja($1), expresion_ptr);
    }

/*Regla n12*/
mostrar: DISPLAY factor {
        printf("\nRegla 12.1: DISPLAY Valor numerico");
        mostrar_ptr = crearNodo("DISPLAY", factor_ptr, NULL);
    }
    | DISPLAY STRING_CTE {
        printf("\nRegla 12.2: DISPLAY String constante");
        mostrar_ptr = crearNodo("DISPLAY", crearHoja($2), NULL);
    }
    
/*Regla n13*/
obtener: GET ID {
        printf("\nRegla 13: GET"); // Entrada por teclado
        if(buscar_simbolo($2, VARIABLE_NUM) == -1){yyerror("Variable desconocida");YYABORT;};
        obtener_ptr = crearNodo("GET", crearHoja($2), NULL);
    } 

/*Regla n14*/
condicion: cond_s {aux_cond_s_ptr = cond_s_ptr;} AND cond_s {
        printf("\nRegla 14.1 Condicion anidada por AND ");
        condicion_ptr = crearNodo("AND", aux_cond_s_ptr, cond_s_ptr);
        pila_cond[pila_cond_tope++] = condicion_ptr;
    }
    | cond_s {aux_cond_s_ptr = cond_s_ptr;} OR cond_s {
        printf("\nRegla 14.2 Condicion anidada por OR ");
        condicion_ptr = crearNodo("OR", aux_cond_s_ptr, cond_s_ptr);
        pila_cond[pila_cond_tope++] = condicion_ptr;
    }
    | NOT cond_s {
        printf("\nRegla 14.3 Condicion negada ");
        condicion_ptr = crearNodo("NOT", cond_s_ptr, NULL);
        pila_cond[pila_cond_tope++] = condicion_ptr;
    }
    | cond_s {
        printf("\nRegla 14.4 Condicion simple ");
        condicion_ptr = cond_s_ptr;
        pila_cond[pila_cond_tope++] = condicion_ptr;
    }

/*Regla n15*/
cond_s : factor {aux_factor_ptr = factor_ptr;} MAYOR factor {
        cond_s_ptr = crearNodo(">", aux_factor_ptr, factor_ptr);
    }
    | factor {aux_factor_ptr = factor_ptr;} MAYOR_IGUAL factor {
        cond_s_ptr = crearNodo(">=", aux_factor_ptr, factor_ptr);
    }
    | factor {aux_factor_ptr = factor_ptr;} MENOR factor {
        cond_s_ptr = crearNodo("<", aux_factor_ptr, factor_ptr);
    }
    | factor {aux_factor_ptr = factor_ptr;} MENOR_IGUAL factor {
        cond_s_ptr = crearNodo("<=", aux_factor_ptr, factor_ptr);
    }
    | factor {aux_factor_ptr = factor_ptr;} IGUAL factor {
        cond_s_ptr = crearNodo("==", aux_factor_ptr, factor_ptr);
    }
    | factor {aux_factor_ptr = factor_ptr;} DISTINTO factor {
        cond_s_ptr = crearNodo("!=", aux_factor_ptr, factor_ptr);
    }

/*Regla n16*/
expresion: expresion MAS termino {
        printf("\nRegla 16.1: SUMA ");
        expresion_ptr = crearNodo("+", expresion_ptr, termino_ptr);
    }
    | expresion MENOS termino {
        printf("\nRegla 16.2: RESTA ");
        expresion_ptr = crearNodo("-", expresion_ptr, termino_ptr);
    }
    | termino {
        printf("\nRegla 16.3: termino ");
        expresion_ptr = termino_ptr;
    }

/*Regla n17*/
termino: termino MULT factor {
        printf("\nRegla 17.1: MULTIPLICACION ");
        termino_ptr = crearNodo("*", termino_ptr, factor_ptr);
    }
    | termino DIV factor {
        printf("\nRegla 17.2: DIVISION ");
        termino_ptr = crearNodo("/", termino_ptr, factor_ptr);
    }
    | factor {
        printf("\nRegla 17.3: factor ");
        termino_ptr = factor_ptr;
    }

/*Regla n18*/
factor: PAR_ABR expresion PAR_CIE 
    {//printf("\nRegla 18.1: factor -> PAR_ABR expresion PAR_CIE ");
        factor_ptr = expresion_ptr;
    }
    | ID 
    {//{printf("\nRegla 18.2: factor -> ID ");}
        if(buscar_simbolo($1, VARIABLE_NUM) == -1){yyerror("Variable desconocida");YYABORT;};
        
        factor_ptr = crearHoja($1);
    }

    | NUM_ENTERO 
    {//printf("\nRegla 18.3: factor -> NUM_ENTERO ");
        snprintf (_aux_str, sizeof(_aux_str), "%d",$1);
        factor_ptr = crearHoja(_aux_str);
    } 
    | NUM_REAL  
    {//printf("\nRegla 18.4: factor -> NUM_REAL ");
        snprintf (_aux_str, sizeof(_aux_str), "%f",$1);
        factor_ptr = crearHoja(_aux_str);

    } 

/*Regla n19*/
longitud: LONG PAR_ABR contar PAR_CIE 
    {
        printf("\nRegla 19: Longitud de la lista");
        snprintf (_aux_str, sizeof(_aux_str), "%d",_longitud_total);
        longitud_ptr = crearHoja(_aux_str);
    }

/*Regla n20*/
contar: contar COMA ID 
    {//printf("\nRegla 20.1: contar -> contar COMA ID");
        if(buscar_simbolo($3, VARIABLE_NUM) == -1){ yyerror("\nVariable desconocida"); YYABORT;};

        _longitud_total++;
    }
        | ID 
    {//printf("\nRegla 20.2: contar -> ID");
        if(buscar_simbolo($1, VARIABLE_NUM) == -1){yyerror("\nVariable desconocida");YYABORT;};
        
        _longitud_total = 1;
    }

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

    abrir_archivo_arbol();

    yyparse();

    guardar_tabla();
    liberar_tabla();

    cerrar_archivo_arbol();

    fclose(yyin);

    return 0;
}



