#ifndef ASSEMBLER_H
#define ASSEMBLER_H

void generar_assembler();
void recorrer(t_nodo *nodo);
void expresion_matematica(t_nodo* expr);
void identificar_condicion(t_nodo* nodo, char* tipo, int nro);
void primeras_lineas_condicion(t_nodo* nodo);
void equivalencia_condicion(char* cond, int not);
void imprimir_encabezado();
void imprimir_tabla_simbolo();
void imprimir_cierre();
void cond_simple(t_nodo* nodo, char* tipo, int nro, int not);
char* formato_num(char* cad);

#endif