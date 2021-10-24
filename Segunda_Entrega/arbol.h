#ifndef ARBOL_H
#define ARBOL_H


typedef struct nodo {
    int nro_nodo;
    char* valor;
    struct nodo *h_izq, *h_der;
} t_nodo;

t_nodo* crearNodo(char* valor,t_nodo* hijoIzq, t_nodo* hijoDer);
t_nodo* crearHoja(char* valor);
void abrir_archivo_arbol();
void cerrar_archivo_arbol();
void guardar_nodo(t_nodo* tmp);

#endif