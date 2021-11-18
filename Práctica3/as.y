%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(const char* msg);
int yylex();

int linea_actual = 1 ;
int error_lexico = 0 ;
int error_sintactico = 0 ;

#define YYDEBUG 1
#define YYERROR_VERBOSE
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
%token PROCEDIMIENTO
%token OP_ASIG
%token SI
%token SINO 
%token MIENTRAS 
%token HACER
%token HASTA
%token PARENT_IZQ
%token PARENT_DER
%token CONSTANTE
%token NATURAL 
%token CADENA 
%token ENTRADA 
%token SALIDA 
%token CORCHETE_IZQ
%token CORCHETE_DER
%token MASMENOS
%token PYC

%left   OPMATRICES
%left	MASMENOS
%left   OP_BINARIO
%right  OP_UNARIO

%start Principal 

%%
/** Sección de producciones de la gramática.    **/

Principal             	:   PRINCIPAL bloque 	;

bloque 					:   INICIO_BLOQUE
							Declar_de_var_locales
							Declar_de_subprogs
							FIN_BLOQUE    

						| 	INICIO_BLOQUE
							Declar_de_var_locales
							Declar_de_subprogs
							Sentencias
							FIN_BLOQUE ;

Declar_de_var_locales   :   MARCA_INICIO_VAR Variables_locales 
							MARCA_FIN_VAR
                        |   ;

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var 	
						|   error{yyerrok;yyclearin;}   ;


Cuerpo_declar_var       :   TIPO Identificadores PYC
						| 	TIPO Arrays PYC		;

Arrays 					: 	Arrays COMA Array
						| 	Array 	;

Array 					: 	ID CORCHETE_IZQ expresion CORCHETE_DER	
						|	ID CORCHETE_IZQ expresion COMA expresion 
							CORCHETE_DER;

Identificadores		    :   Identificadores COMA ID 
                        |   ID
                        |	error{yyerrok;yyclearin;} 	;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog   
						|	;

Declar_subprog          : 	PROCEDIMIENTO ID
                            PARENT_IZQ Parametros PARENT_DER 
                            bloque 	;

Parametros			    :   Parametros COMA Parametro   
                        |   Parametro
                        |   error{yyerrok;yyclearin;}
                        |	;

Parametro				:   TIPO ID 	;

Sentencias 			    :   Sentencias Sentencia
						| 	Sentencia 	;

Sentencia 			    :   bloque
						| 	sentencia_asignacion
						| 	sentencia_si
						| 	sentencia_mientras
						|	sentencia_hacer
						|	sentencia_entrada
						| 	sentencia_salida
						| 	llamada_proced 	;

sentencia_asignacion	:   Ide_exp OP_ASIG expresion PYC ;

Ide_exp 				:	ID | Array_exp 	
						|   error{yyerrok;yyclearin;}   ;


Array_exp 				:	ID CORCHETE_IZQ expresion CORCHETE_DER 
			  			|	ID CORCHETE_IZQ expresion COMA expresion 
			  				CORCHETE_DER 	;

sentencia_si			:   si SINO Sentencia 	;

si 						:	SI PARENT_IZQ expresion PARENT_DER 
							Sentencia 	;

sentencia_mientras		:   MIENTRAS PARENT_IZQ expresion PARENT_DER
                            Sentencia 	;

sentencia_hacer			:   HACER bloque HASTA PARENT_IZQ expresion 
							PARENT_DER PYC 	;

sentencia_entrada 		: 	ENTRADA Identificadores 	;

sentencia_salida 		: 	SALIDA lista_exp_cadena 	;

lista_exp_cadena 		: 	lista_exp_cadena COMA exp_cadena 
						|	exp_cadena 	;

exp_cadena 				: 	expresion | CADENA 	;

llamada_proced		    :   ID PARENT_IZQ argumentos PARENT_DER PYC
						|	ID PARENT_IZQ PARENT_DER PYC
						|   error{yyerrok;yyclearin;}   ;

argumentos              :   argumentos COMA expresion
                        |   expresion 	
						|   error{yyerrok;yyclearin;}   ;

expresion				:   PARENT_IZQ expresion PARENT_DER
						| 	ID
						| 	Constante						
                        | 	OP_UNARIO expresion
						| 	MASMENOS expresion 
						| 	expresion OP_BINARIO expresion
						| 	expresion MASMENOS expresion 
                        |   expresion OPMATRICES expresion
						|	Array_exp
						| 	Agregados 	;

Agregados 				:	INICIO_BLOQUE argumentos FIN_BLOQUE	;
						|	INICIO_BLOQUE 
							argumentos PYC argumentos
							CORCHETE_DER ;


Constante				:   CONSTANTE | NATURAL		;

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
	fprintf(stderr,"[Linea %d] Error %i: %s\n", linea_actual, error_sintactico, msg);
}
