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
%token PROCEDIMIENTO
%token OP_ASIGNACION
%token SI
%token SINO 
%token MIENTRAS 
%token HACER
%token HASTA
%token END
%token PARENT_IZQ
%token PARENT_DER
%token CONSTANTE
%token CADENA 
%token ENTRADA 
%token SALIDA 
%token NATURAL 


%left   OPMATRICES
%left   OP_BINARIO
%right  OP_UNARIO
%left   OP_BINARIO
%right  OP_UNARIO

%%
/** Sección de producciones de la gramática.    **/

Principal             :   PRINCIPAL bloque 	;    

bloque:                     INICIO_BLOQUE
							Declar_de_var_locales
							Declar_de_subprogs
						    Sentencias
						    FIN_BLOQUE    
                        |   INICIO_BLOQUE   /* Vacio */   FIN_BLOQUE 	;

Declar_de_var_locales   :   MARCA_INICIO_VAR Variables_locales MARCA_FIN_VAR
                        |   ; 

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var 	;

Cuerpo_declar_var       :   TIPO Identificadores PYC
						| 	TIPO Arrays PYC
						|   error 	;

Arrays 					: 	Arrays COMA Array
						| 	Array 	;

Array 					: 	ID CORCHETE_IZQ NATURAL CORCHETE_DER
		   				| 	ID CORCHETE_IZQ NATURAL COMA NATURAL CORCHETE_DER ;

Identificadores		    :   Identificadores COMA ID 
                        |   ID
                        |   ;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog   
						|	;

Declar_subprog          :  PROCEDIMIENTO ID
                            PARENT_IZQ Parametros PARENT_DER 
                            bloque 	;

Parametros			    :   Parametros COMA Parametro   
                        |   Parametro
                        |   error 	;

Parametro				:   TIPO ID 	;


Sentencias 			    :   Sentencias Sentencia
						| 	Sentencia 	;
Sentencia 			    :   bloque
						| 	sentencia_asignacion
						| 	sentencia_si
						| 	sentencia_mientras
						|	sentencia_hacer
						| 	sentencia_salida
						| 	llamada_proced 	;

sentencia_asignacion	:   Ide_exp OP_ASIGNACION expresion PYC
					 	| 	Ide_exp OP_ASIGNACION Array_exp PYC 	;

Ide_exp 				: ID | Array_exp 	;

Array_exp 				: ID CORCHETE_IZQ expresion CORCHETE_DER 
			  			| ID CORCHETE_IZQ expresion COMA expresion CORCHETE_DER 	;


// Conflicto desplazamiento/reduccion
sentencia_si			:   SI PARENT_IZQ expresion PARENT_DER 
                            Sentencia
						| 	SI PARENT_IZQ expresion PARENT_DER 
                            Sentencia
							SINO Sentencia 	;

sentencia_mientras		    :   MIENTRAS PARENT_IZQ expresion PARENT_DER
                            Sentencia   ;

sentencia_hacer			:   HACER Sentencia HASTA PARENTESIS_IZQ expresion PARENT_DER PYC 	;

sentencia_entrada 		: 	ENTRADA Identificadores 	;

sentencia_salida 		: 	SALIDA lista_exp_cadena 	;

lista_exp_cadena 		: 	lista_exp_cadena COMA exp_cadena | exp_cadena 	;

exp_cadena 				: 	expresion | CADENA 	;

llamada_proced		    :   ID PARENT_IZQ argumentos PARENT_DER PYC 	;

argumentos              :   argumentos COMA argumento
                        |   argumento
                        |   ;

argumento               :   Constante | Booleano | ID    ;

expresion				:   PARENT_IZQ expresion PARENT_DER
						| 	ID
                        | 	OP_UNARIO expresion
						| 	MASMENOS expresion 
						| 	expresion OP_BINARIO expresion
						| 	expresion MASMENOS expresion 
						| 	Constante
						|	Array_exp
						| 	Agregados
                        |   expresion OPMATRICES expresion 
                        |   error   ;

Agregados 				: 	INICIO_BLOQUE agregado1d FIN_BLOQUE 
			  			| 	INICIO_BLOQUE agregado2d FIN_BLOQUE 	;



/*agregado1d 				: 	CORCHETE_IZQ expresiones 	;*/

/*agregado2d 				: CORCHETE_IZQ agregado*/



Constante				:   CONSTANTE | NATURAL | Booleano | CADENA    ;
Booleano				:   "verdadero" | "falso"   ;

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

