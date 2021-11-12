%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
//#include "y.tab.h"

void yyerror(const char* msg);
int yylex();

int linea_actual = 1 ;
int error_lexico = 0 ;
int error_sintactico = 0 ;
//int objeto = 1;
%}

%define parse.error verbose

/** A continuación declaramos los tokens/símbolos terminales de la gramática.   **/
%token MARCA_INICIO_VAR
%token MARCA_FIN_VAR
%token PRINCIPAL
%token INICIO_BLOQUE
%token FIN_BLOQUE
%token COMA
%token ID
%token TIPO
%token LISTA
%token CABECERA_SUBPROG
%token OP_ASIGNACION
%token IF
%token ELSE
%token WHILE
%token FOR
%token TO
%token BEG
%token END
%token PARENTESIS_IZQ
%token PARENTESIS_DER
%token CONSTANTE
%token PALABRA

%right  OP_INICIO_LISTA
%left   OP_RECORRIDO_LISTA
//%left   OP_ADD_LISTA
%left   OP_POS_LISTA
%right  OP_UNARIO_LISTA
%left   OP_BINARIO_LISTA

%left   OP_COMPUESTO
%left   OP_BINARIO
%right  OP_NEG

%%
/** Sección de producciones de la gramática.    **/

Principal               :   PRINCIPAL bloque    ;    

bloque:                     INICIO_BLOQUE
							Declar_de_var_locales
							Declar_de_subprogs
						    Sentencias
						    FIN_BLOQUE    
                        |   INICIO_BLOQUE   /* Vacio */   FIN_BLOQUE;

Declar_de_var_locales   :   MARCA_INICIO_VAR Variables_locales MARCA_FIN_VAR
                            |   ; 

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var   ;

Cuerpo_declar_var       :   TIPO Identificadores
                        |   LISTA TIPO Identificadores
                        |   error   ;

Identificadores		    :   Identificadores COMA ID 
                        |   ID
                        |   ;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog 
						|   ;

Declar_subprog          :   CABECERA_SUBPROG ID
                            PARENTESIS_IZQ Parametros PARENTESIS_DER 
                            bloque  ;

Parametros			    :   Parametros COMA Parametro   
                        |   Parametro
                        |   error ;

Parametro				:   TIPO ID ;


Sentencias 			    :   Sentencias Sentencia
						| 	Sentencia   ;
Sentencia 			    :   bloque
						| 	sentencia_asignacion
						|	sentencia_listas
						| 	sentencia_if
						| 	sentencia_while
						|	sentencia_for
						| 	llamada_proced  ;

sentencia_asignacion	:   ID OP_ASIGNACION expresion  ;

// Conflicto desplazamiento/reduccion
sentencia_if			:   IF PARENTESIS_IZQ expresion PARENTESIS_DER 
                            Sentencia
						|	IF PARENTESIS_IZQ expresion PARENTESIS_DER 
                            Sentencia
							ELSE Sentencia  ;

sentencia_while		    :   WHILE PARENTESIS_IZQ expresion PARENTESIS_DER
                            Sentencia   ;

sentencia_for			:   FOR sentencia_asignacion TO expresion
								Sentencia
						|	FOR sentencia_asignacion TO expresion
								BEG Sentencia END   ;

llamada_proced		    :   ID PARENTESIS_IZQ argumentos PARENTESIS_DER ;

argumentos              :   argumentos COMA argumento
                        |   argumento
                        |   ;

argumento               :   Constante | Booleano | Real | ID    ;

sentencia_listas		:   expresion OP_RECORRIDO_LISTA
						|	OP_INICIO_LISTA expresion
						|	expresion OP_BINARIO_LISTA expresion   
                        ;

expresion				:   PARENTESIS_IZQ expresion PARENTESIS_DER
						| 	ID
                        | 	OP_NEG expresion
                        | 	expresion OP_COMPUESTO expresion
						| 	expresion OP_BINARIO expresion
						| 	Constante
						
						|	OP_UNARIO_LISTA expresion
                        |   expresion OP_POS_LISTA expresion
                        |   error   ;

Constante				:   CONSTANTE | Real | Booleano | PALABRA    ;
Booleano				:   "TRUE" | "FALSE"   ;
Real					:   CONSTANTE "." CONSTANTE ;

%%

/** Incluimos el fichero generado por el ’lex’
*** que implementa la función ’yylex’   **/

#ifdef DOSWINDOWS
#include "lexyy.c"
#else
#include "lex.yy.c"
#endif

void yyerror(const char* msg )
{
    error_sintactico ++;
	fprintf(stderr,"[Linea %d] Error numero %i: %s\n", yylineno, error_sintactico, msg);
}

