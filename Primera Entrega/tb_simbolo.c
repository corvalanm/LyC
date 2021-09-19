#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tb_simbolo.h"

t_simbolo tabla [TAM_ARRAY];
int ultimo = -1;

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

void mostrar_tabla() {
    int i = 0;
    printf("\n\n***** Tabla *****");
    printf("\n%-20s |%-9s |%-30s |%-10s", "NOMBRE", "TIPO", "VALOR", "LONGITUD");
    while(i <= ultimo) {
        //printf("\nNombre: %s, Tipo de dato: %d, ", tabla[i].name, tabla[i].tipo_dato);
        printf("\n%-20s |", tabla[i].name);
        if(tabla[i].tipo_dato == INT_CONST){
            //printf("Valor: %d",*(int*)tabla[i].valor);
            printf("%-9s |%-30d |", "Int", *(int*)tabla[i].valor);
            //free(tabla[i].valor);
        } 

        if(tabla[i].tipo_dato == REAL_CONST){
            printf("%-9s |%-30f |", "Float", *(float*)tabla[i].valor);
            //printf("Valor: %f",*(float*)tabla[i].valor);
            //free(tabla[i].valor);
        }
        
        if(tabla[i].tipo_dato == STR_CONST){
            //printf("Valor: %s, Longitud: %d",(char*)tabla[i].valor, tabla[i].longitud);
            printf("%-9s |%-30s |%-10d","char*" ,(char*)tabla[i].valor, tabla[i].longitud);
        }

        if(tabla[i].tipo_dato == INT_VAR){
            printf("%-9s |%-30s |","Int", "-");
        }

        if(tabla[i].tipo_dato == REAL_VAR){
            printf("%-9s |%-30s |", "Float", "-");
        }

        free(tabla[i].valor);
        free(tabla[i].name);
        i++;
    }
    printf("\n***** Tabla *****\n");
}

void liberar_tabla() {
    int i = 0;
    while(i <= ultimo) {
        
        if(tabla[i].tipo_dato == INT_CONST){
            free(tabla[i].valor);
        } 

        if(tabla[i].tipo_dato == REAL_CONST){
            free(tabla[i].valor);
        }
        
        if(tabla[i].tipo_dato == STR_CONST){
            free(tabla[i].valor);
        }
        free(tabla[i].name);
        i++;
    }
}

int get_ultimo() {
    return ultimo;
}