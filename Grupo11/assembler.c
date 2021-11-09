#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "arbol.h"
#include "assembler.h"
#include "tb_simbolo.h"

t_nodo* aux;
char cond_assembler[5];
char aux_char[500];
FILE *fp;

void generar_assembler(t_nodo *raiz) {
    fp = fopen("Final.asm", "wt");

    if(fp == NULL) {
        perror("Error abrir el archivo!");
        exit(1);
    }

    imprimir_encabezado();
    imprimir_tabla_simbolo();

    
    fprintf(fp, "\n.CODE\n");
    fprintf(fp, "START:\n");
    fprintf(fp, "mov AX,@DATA\n");
    fprintf(fp, "mov DS,AX\n");
    fprintf(fp, "mov es,ax\n\n");
    recorrer(raiz);
    imprimir_cierre();

    fclose(fp);
}

void recorrer(t_nodo *nodo) {
    if (nodo != NULL) {
        recorrer(nodo->h_izq);
        
        
        if (!strcmp(nodo->valor, "IF")) {
            if (!strcmp(nodo->h_der->valor, "CUERPO")) {

                identificar_condicion(nodo->h_izq, "IF_ELSE", nodo->nro_nodo);
                fprintf(fp, "then_part_%d: \n",nodo->nro_nodo);
                recorrer(nodo->h_der->h_izq);

                fprintf(fp, "JMP endIF_ELSE_%d \n",nodo->nro_nodo); //agregar salto a enf_if_NRO
                fprintf(fp, "else_IF_ELSE_%d:\n", nodo->nro_nodo); //AGREGAR ETIQ de else
                recorrer(nodo->h_der->h_der);
                fprintf(fp, "endIF_ELSE_%d: \n",nodo->nro_nodo);

            } else {
                if (!strcmp(nodo->h_izq->h_izq->valor, "+")||!strcmp(nodo->h_izq->h_izq->valor, "-")||!strcmp(nodo->h_izq->h_izq->valor, "*")||!strcmp(nodo->h_izq->h_izq->valor, "/")) {
                    expresion_matematica(nodo->h_izq->h_izq);
                    fprintf(fp, "fstp _aux_math \n");
                    strcpy(nodo->h_izq->h_izq->valor, "_aux_math");
                    nodo->h_izq->h_der = nodo->h_izq->h_izq = NULL;
                }

                if (!strcmp(nodo->h_izq->h_der->valor, "+")||!strcmp(nodo->h_izq->h_der->valor, "-")||!strcmp(nodo->h_izq->h_der->valor, "*")||!strcmp(nodo->h_izq->h_der->valor, "/")) {
                    expresion_matematica(nodo->h_izq->h_der);
                    fprintf(fp, "fstp _aux_math \n");
                    strcpy(nodo->h_izq->h_der->valor, "_aux_math");
                }
                
                identificar_condicion(nodo->h_izq, "IF", nodo->nro_nodo);
                fprintf(fp, "then_IF_%d: \n",nodo->nro_nodo);
                recorrer(nodo->h_der);
                fprintf(fp, "endIF_%d: \n",nodo->nro_nodo); // agregar etiq de fin de IF
            }
            
            return;
        }

        if (!strcmp(nodo->valor, "WHILE")) {
            fprintf(fp, "WHILE_%d: \n",nodo->nro_nodo);
            identificar_condicion(nodo->h_izq, "WHILE", nodo->nro_nodo);
            recorrer(nodo->h_der);
            fprintf(fp, "JMP WHILE_%d \n",nodo->nro_nodo);
            fprintf(fp, "endWHILE_%d: \n",nodo->nro_nodo);

            return;
        }

        if (!strcmp(nodo->valor, "WHILE_ESP")) {
            //recorrer(nodo->h_izq->h_izq); // lista de expresiones
            identificar_condicion(nodo->h_izq->h_der, "WHILE_ESP", nodo->nro_nodo);
            recorrer(nodo->h_der);
            fprintf(fp, "endWHILE_ESP_%d: \n",nodo->nro_nodo);
            nodo->h_izq = nodo->h_der = NULL;
            return;
        }

        if (!strcmp(nodo->valor, "DISPLAY")) {
            if (buscar_simbolo(nodo->h_izq->valor, STR_CONST) == -1) {
                fprintf(fp, "DisplayFloat %s,3\n", nodo->h_izq->valor);

            } else {
                fprintf(fp, "mov dx,OFFSET %s\n", get_name(buscar_simbolo(nodo->h_izq->valor, STR_CONST)) );
                fprintf(fp, "mov ah,9\n");
                fprintf(fp, "int 21h\n");
            }
            
            
            //fprintf(fp, "newline 1\n");

            // NUEVA LINEA
            
            fprintf(fp, "MOV dl, 10 \n");
            fprintf(fp, "MOV ah, 02h \n");
            fprintf(fp, "INT 21h \n");
            fprintf(fp, "MOV dl, 13 \n");
            fprintf(fp, "MOV ah, 02h \n");
            fprintf(fp, "INT 21h \n");
            
            return;
        }

        if (!strcmp(nodo->valor, "GET"))
        {
            fprintf(fp, "mov dx,OFFSET _Ingrese_un_numero\n");
            fprintf(fp, "mov ah,9\n");
            fprintf(fp, "int 21h\n");
            //fprintf(fp, "newline 1\n");
            // NUEVA LINEA
            
            fprintf(fp, "MOV dl, 10 \n");
            fprintf(fp, "MOV ah, 02h \n");
            fprintf(fp, "INT 21h \n");
            fprintf(fp, "MOV dl, 13 \n");
            fprintf(fp, "MOV ah, 02h \n");
            fprintf(fp, "INT 21h \n");
            

            fprintf(fp, "GetFloat %s\n", nodo->h_izq->valor);
            fprintf(fp, "fld %s\n", nodo->h_izq->valor);

            return;
        }
        

        if (!strcmp(nodo->valor, ":="))
        {
            expresion_matematica(nodo->h_der);
            fprintf(fp, "fstp %s \n", nodo->h_izq->valor);

            return;
        }
        
        recorrer(nodo->h_der);
    }
    
}

void expresion_matematica(t_nodo* expr){
    if (!strcmp(expr->valor, "+")) {
        expresion_matematica(expr->h_izq);
        expresion_matematica(expr->h_der);
        fprintf(fp, "fadd\n");
    } else if (!strcmp(expr->valor, "-")) {
        expresion_matematica(expr->h_izq);
        expresion_matematica(expr->h_der);
        fprintf(fp, "fsub\n");
    } else if (!strcmp(expr->valor, "*")) {
        expresion_matematica(expr->h_izq);
        expresion_matematica(expr->h_der);
        fprintf(fp, "fmul\n");
    } else if (!strcmp(expr->valor, "/")) {
        expresion_matematica(expr->h_izq);
        expresion_matematica(expr->h_der);
        fprintf(fp, "fdiv\n");
    } else {
        fprintf(fp, "fld %s\n", formato_num(expr->valor));
    }
}

void identificar_condicion(t_nodo* nodo, char* tipo, int nro) { 
    if (!strcmp(nodo->valor, "OR")) {
        cond_simple(nodo->h_izq, tipo, nro, 1);
        cond_simple(nodo->h_der, tipo, nro, 0);   

    } else if (!strcmp(nodo->valor, "AND")) {
        cond_simple(nodo->h_izq, tipo, nro, 0);
        cond_simple(nodo->h_der, tipo, nro, 0);      

    } else if (!strcmp(nodo->valor, "NOT")) {
        cond_simple(nodo->h_izq, tipo, nro, 1);
    } else {
        cond_simple(nodo, tipo, nro, 0);
    }
}

void cond_simple(t_nodo* nodo, char* tipo, int nro, int not) {
    primeras_lineas_condicion(nodo);
    equivalencia_condicion(nodo->valor, not);
    
    if (!strcmp(tipo, "IF_ELSE"))
        fprintf(fp, "%s else_%s_%d \n", cond_assembler, tipo, nro);
    else 
        fprintf(fp, "%s end%s_%d \n", cond_assembler, tipo, nro);
}

void primeras_lineas_condicion(t_nodo* nodo) {
    
    fprintf(fp,"fld %s \n", formato_num(nodo->h_izq->valor));
    fprintf(fp, "fcomp %s \n", formato_num(nodo->h_der->valor));
    fprintf(fp, "fstsw ax \n");
    fprintf(fp, "sahf \n");
}

char* formato_num(char* cad) {
    if (isdigit(cad[0])) {
        sprintf (aux_char, "_%s", quitar_punto(cad));
        return aux_char;
    }
    return cad;
}

void equivalencia_condicion(char* cond, int not) {
    
    if (!strcmp(cond, ">")) {
        if (not)
            strcpy(cond_assembler, "JNBE"); // salta si se cumple ">" 
        else
            strcpy(cond_assembler, "JBE"); // salta si se cumple "<=" 
        return;
    }   

    if (!strcmp(cond, ">=")) {
        if (not)
            strcpy(cond_assembler, "JNB");
        else
            strcpy(cond_assembler, "JB");
        return;
    }   

    if (!strcmp(cond, "<")) {
        if (not)
            strcpy(cond_assembler, "JB");
        else
            strcpy(cond_assembler, "JNB");
        return;
    }   

    if (!strcmp(cond, "<=")) {
        if (not)
            strcpy(cond_assembler, "JBE");
        else
            strcpy(cond_assembler, "JNBE");
        return;
    }   

    if (!strcmp(cond, "!=")) {
        if (not)
            strcpy(cond_assembler, "JNE");
        else
            strcpy(cond_assembler, "JE");
        return;
    }   

    if (!strcmp(cond, "==")) {
        if (not)
            strcpy(cond_assembler, "JE");
        else
            strcpy(cond_assembler, "JNE");
        return;
    }  
    
    if (!strcmp(cond, "==")) {
        if (not)
            strcpy(cond_assembler, "JE");
        else
            strcpy(cond_assembler, "JNE");
        return;
    }  

}

void imprimir_encabezado() {
    //fprintf(fp, "include macros2.asm\n");
    fprintf(fp, "include number.asm\n\n");
    fprintf(fp, ".MODEL  LARGE\n");
    fprintf(fp, ".386\n");
    fprintf(fp, ".STACK 200h\n");
}
void imprimir_tabla_simbolo() {
    fprintf(fp, "\n.DATA\n");

    guardar_tabla_assembler(fp);

    fprintf(fp, "_Ingrese_un_numero         db  \"Ingrese un numero\",'$', 33 dup (?)\n");
    fprintf(fp, "_aux_math \t dd \t ?\n");
    fprintf(fp, "_ejec_while_esp \t dd \t ?\n");
}

void imprimir_cierre() {
    fprintf(fp, "\n\nmov ax, 4C00h\n");
    fprintf(fp, "int 21h\n");
    fprintf(fp, "end START\n");
}