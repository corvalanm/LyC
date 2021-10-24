#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbol.h"


FILE *f;
int nodo_creados = 0;

t_nodo* crearNodo(char* valor, t_nodo* hijoIzq, t_nodo* hijoDer){
    t_nodo* tmp;
    tmp = (t_nodo*)malloc(sizeof(t_nodo));

    tmp->nro_nodo = ++nodo_creados;
    tmp->valor = valor;

    tmp->h_izq = hijoIzq;
    tmp->h_der = hijoDer;

    guardar_nodo(tmp);

    return tmp;
}
t_nodo* crearHoja(char* valor){
    t_nodo* tmp;
    tmp = (t_nodo*)malloc(sizeof(t_nodo));

    tmp->nro_nodo = ++nodo_creados;
    tmp->valor = valor;

    tmp->h_izq = tmp->h_der = NULL;

    guardar_nodo(tmp);

    return tmp;
}

void abrir_archivo_arbol(){
    f = fopen("intermedia.txt", "w");
    if (f == NULL)
    {
        printf("Error al intentar abrir el archivo \"intermedia.txt\".\n");
        exit(1);
    }
    
    fprintf(f,"Nro Contenido [H_izq_Contenido H_izq_nro] [H_der_Contenido H_der_nro]\n");
}

void cerrar_archivo_arbol(){
    fclose(f);
}

void guardar_nodo(t_nodo* tmp){
    fprintf(f,"\n%d %s", nodo_creados, tmp->valor);

    if (tmp->h_izq != NULL)
        fprintf(f," [%s %d]", tmp->h_izq->valor, tmp->h_izq->nro_nodo);

    if (tmp->h_der != NULL)
        fprintf(f," [%s %d]", tmp->h_der->valor, tmp->h_der->nro_nodo);
}