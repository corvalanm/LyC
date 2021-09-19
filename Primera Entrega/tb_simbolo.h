#ifndef TB_SIMBOLO_H
#define TB_SIMBOLO_H

#define TAM_ARRAY 100
    
#define INT_VAR 1
#define INT_CONST 2
#define REAL_VAR 3
#define REAL_CONST 4
#define STR_CONST 5
#define VARIABLE_NUM 10

typedef struct simbolo {
    char *name;
    int tipo_dato;
    void *valor;
    int longitud;
} t_simbolo;

void mostrar_tabla();
void agregar_simbolo(char* nombre, int td, void* valor);
int buscar_simbolo(char* aComparar, int tipo_dato);

#endif