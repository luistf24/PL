%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "include/ts.h"

void yyerror(const char* msg);
int yylex();

int linea_actual = 1 ;
int error_lexico = 0 ;
int error_sintactico = 0 ;

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
%token ENTONCES
%token SINO
%token MIENTRAS
%token HACER
%token HASTA
%token CONSTANTE
%token NATURAL
%token CADENA
%token ENTRADA
%token SALIDA
%token PYC
%token PARENT_IZQ
%token PARENT_DER
%token CORCHETE_IZQ
%token CORCHETE_DER

%left   OP_OR
%left	OP_AND
%left	OP_XOR
%left	OP_IGUALDAD
%left	OP_REL
%left	MASMENOS
%left	OP_MULT
%right  OP_NOT

%start Principal

%%
/** Sección de producciones de la gramática.    **/

Principal             	:   PRINCIPAL bloque 	;

bloque 					:   INICIO_BLOQUE {
								tipoEntrada a=marca;
								dtipo b = desconocido;
								entradaTS marca = {.entrada=a, .nombre="marca", .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1=0, .TamDimen2=0};

								TS_Inserta(marca);
								} Declar_de_var_locales	Declar_de_subprogs FIN_BLOQUE { TS_VaciarBloque();}

						| 	INICIO_BLOQUE {
														tipoEntrada a=marca;
														dtipo b = desconocido;
														entradaTS marca = {.entrada=a, .nombre="marca", .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1=0, .TamDimen2=0};

														TS_Inserta(marca);
														}

						Declar_de_var_locales Declar_de_subprogs Sentencias FIN_BLOQUE { TS_VaciarBloque();} ;

Declar_de_var_locales   :   MARCA_INICIO_VAR Variables_locales MARCA_FIN_VAR
                        |   ;

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var 	;

Cuerpo_declar_var       :   tipo linea_variables PYC
						|	tipo linea_variables error 	;

// Definido para no confundir con <Parametro>
tipo					:	TIPO | error 	;

linea_variables			:	linea_variables COMA variable
						|	variable	;

variable 				:	ID | Array ;

Array 					: 	ID CORCHETE_IZQ expresion CORCHETE_DER
						|	ID CORCHETE_IZQ expresion COMA expresion CORCHETE_DER;

Identificadores		    :   Identificadores COMA ID
                        |   ID
                        | 	error ;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog
						|	;

Declar_subprog          : 	PROCEDIMIENTO ID {
tipoEntrada a=procedimiento;
dtipo b = no_asignado;
														entradaTS procedimiento = {.entrada=a, .nombre=$ID.lexema, .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1=0, .TamDimen2=0};
														TS_Inserta(procedimiento);


} PARENT_IZQ Parametros  {TS[TOPE].parametros = $Parametros.param;} PARENT_DER bloque 	;

Parametros			    :   Parametros COMA Parametro // {$$Parametros.param+=2;} No se que pasa aqui
                        |  Parametro  {$Parametros.param=1+$Parametros.param;}
                        |	{$Parametros.param=0;};

Parametro				:   TIPO ID {$Parametro.tipo = $TIPO.tipo;}
						|	TIPO ID CORCHETE_IZQ CORCHETE_DER {$Parametro.tipo = $TIPO.tipo;}
						|	TIPO ID CORCHETE_IZQ CORCHETE_DER 
									CORCHETE_IZQ CORCHETE_DER {$Parametro.tipo = $TIPO.tipo;}
						|	error	;

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

sentencia_asignacion	:   Ide_exp OP_ASIG expresion PYC  ;

Ide_exp 				:	ID | Array_exp 	;


Array_exp 				:	ID CORCHETE_IZQ expresion CORCHETE_DER
			  			|	ID CORCHETE_IZQ expresion COMA expresion CORCHETE_DER 	;

sentencia_si			:   si
						|	si SINO Sentencia 	;

si 						:	SI PARENT_IZQ expresion PARENT_DER ENTONCES Sentencia 	;

sentencia_mientras		:   MIENTRAS PARENT_IZQ expresion PARENT_DER Sentencia 	;

sentencia_hacer			:   HACER bloque HASTA PARENT_IZQ expresion PARENT_DER PYC 	;

sentencia_entrada 		: 	ENTRADA Identificadores PYC	;

sentencia_salida 		: 	SALIDA lista_exp_cadena PYC	;

lista_exp_cadena 		: 	lista_exp_cadena COMA exp_cadena
						|	exp_cadena 	;

exp_cadena 				: 	expresion | CADENA 	;

llamada_proced		    :   ID PARENT_IZQ argumentos PARENT_DER PYC
						|	ID PARENT_IZQ PARENT_DER PYC
						|   error   ;

argumentos              :   argumentos COMA expresion
                        |   expresion 	;

expresion				:   PARENT_IZQ expresion PARENT_DER
						| 	ID {$expresion.tipo = $ID.tipo;} //comentario
						| 	Constante
                        | 	OP_NOT expresion
						| 	MASMENOS expresion %prec OP_NOT
						| 	expresion OP_OR expresion
						|	expresion OP_AND expresion
						|	expresion OP_XOR expresion
						|	expresion OP_REL expresion
						|	expresion OP_IGUALDAD expresion
						|	expresion OP_MULT expresion
						| 	expresion MASMENOS expresion
						|	Array_exp
						|	Agregados
						| 	error	;

Agregados 				:	INICIO_BLOQUE argumentos FIN_BLOQUE	;
						|	INICIO_BLOQUE argumentos PYC
							argumentos FIN_BLOQUE ;

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
