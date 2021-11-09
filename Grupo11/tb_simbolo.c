#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tb_simbolo.h"

t_simbolo tabla [TAM_ARRAY];
int ultimo = -1;
char aux_name[100];

void agregar_simbolo(char* nombre, int td, void* valor){
    
    if(td == STR_CONST){
        if(buscar_simbolo((char*)valor, td) != -1){ 
            return; // Ya existe en la tabla de simbolos
        }
    } else {
        if(buscar_simbolo(nombre, td) != -1){ 
            return;
        }
    }

    ultimo++;
    tabla[ultimo].name = (char *) malloc(strlen(nombre) + 1);
    strcpy(tabla[ultimo].name, nombre);
    tabla[ultimo].tipo_dato = td;
    
    switch(td) {
        case INT_CONST:
            tabla[ultimo].valor = malloc(sizeof(int));
            memcpy(tabla[ultimo].valor, (int*)valor, sizeof(int));
        break;

        case REAL_CONST:
            tabla[ultimo].valor = malloc(sizeof(float));
            memcpy(tabla[ultimo].valor, (float*)valor, sizeof(float));
        break;

        case STR_CONST:
            tabla[ultimo].valor = malloc(strlen((char*)valor));
            memcpy(tabla[ultimo].valor, (char*)valor, strlen((char*)valor)+1);
            tabla[ultimo].longitud = strlen(((char *)valor));
        break;
    }

}

int buscar_simbolo(char* aComparar, int tipo_dato) {
    int encontrado = -1, i = 0;
    switch(tipo_dato)
    {
        case INT_CONST:
        case INT_VAR:
        case REAL_CONST:
        case REAL_VAR:
        case VARIABLE_NUM:
            while (i <= ultimo && encontrado == -1) {
            if(strcmp(aComparar, tabla[i].name)) {
                i++;
            } else {
                encontrado = i;
            }
        }
        break;

        case STR_CONST:
            while (i <= ultimo && encontrado == -1) {
                if(tabla[i].valor == NULL || strcmp(aComparar, (char*)tabla[i].valor)){
                    i++;
                } else {
                    encontrado = i;
                }
            }
        break;
    }
    
    return encontrado;
}

void guardar_tabla() {
    FILE *f = fopen("ts.txt", "w");
    if (f == NULL)
    {
        printf("Error al intentar abrir el archivo.\n");
        exit(1);
    }
    int i = 0;
    
    fprintf(f,"%-20s |%-15s |%-30s |%-10s", "NOMBRE", "TIPO", "VALOR", "LONGITUD");
    while(i <= ultimo) {
        
        fprintf(f, "\n%-20s |", tabla[i].name);

        if(tabla[i].tipo_dato == INT_CONST){
            fprintf(f, "%-15s |%-30d |", "CTE_INTEGER", *(int*)tabla[i].valor);
        } 

        if(tabla[i].tipo_dato == REAL_CONST){
            fprintf(f, "%-15s |%-30f |", "CTE_FLOAT", *(float*)tabla[i].valor);
        }
        
        if(tabla[i].tipo_dato == STR_CONST){
            fprintf(f, "%-15s |%-30s |%-10d","CTE_STRING" ,(char*)tabla[i].valor, tabla[i].longitud);
        }

        if(tabla[i].tipo_dato == INT_VAR){
            fprintf(f, "%-15s |%-30s |","INTEGER", "-");
        }

        if(tabla[i].tipo_dato == REAL_VAR){
            fprintf(f, "%-15s |%-30s |", "FLOAT", "-");
        }

        i++;
    }

    fclose(f);
}

void liberar_tabla() {
    int i = 0;
    while(i <= ultimo) {
        free(tabla[i].valor);
        free(tabla[i].name);
        i++;
    }
}

int get_ultimo() {
    return ultimo;
}

char* get_name(int index) {
    return tabla[index].name;
}

int buscar_tipo(char* aComparar) {
    int tipoDeDato = -1, i = 0;
    
    while (i <= ultimo && tipoDeDato == -1) {
        if(strcmp(aComparar, tabla[i].name)) {
            i++;
        } else {
            tipoDeDato = tabla[i].tipo_dato == INT_VAR? TIPO_INTEGER : TIPO_REAL;
        }
    }
    
    return tipoDeDato;
}

void guardar_tabla_assembler(FILE *fp) {
    int i = 0;
    
    while(i <= ultimo) {
        if (tabla[i].tipo_dato != STR_CONST)
        {
            if (tabla[i].valor != NULL){
                if (tabla[i].tipo_dato == INT_CONST){
                    fprintf(fp, "%s\tdd\t", tabla[i].name);
                    fprintf(fp, "%f", *(int*)tabla[i].valor*1.0);
                }else{
                    fprintf(fp, "%s\tdd\t", quitar_punto(tabla[i].name));
                    fprintf(fp, "%f", *(float*)tabla[i].valor);
                }
            }
            else{
                fprintf(fp, "%s\tdd\t?", tabla[i].name);
            }
        } else {
            fprintf(fp, "%s\tdb\t\"%s\",'$',%d dup (?)", tabla[i].name, tabla[i].valor, tabla[i].longitud);
        }
        fprintf(fp, "\n");
        i++;
    }
}

char* quitar_punto(char* name) {
    int i = 0;
    strcpy(aux_name, name);
    while (aux_name[i]){
        if (aux_name[i] == '.')
            aux_name[i] = '_';
        i++;
    }
    return aux_name;
}