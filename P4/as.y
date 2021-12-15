%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "TS.h"

void yyerror(const char* msg);
int yylex();

int error_lexico = 0 ;
int error_sintactico = 0 ;
dtipo temp=no_asignado;

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

bloque 					:   INICIO_BLOQUE { TS_AddMark();} 
							Declar_de_var_locales	
							Declar_de_subprogs 
							Resto_bloque	;

Resto_bloque			:	Sentencias 
							FIN_BLOQUE { TS_CleanBlock();}
						|	FIN_BLOQUE { TS_CleanBlock();}	;

Declar_de_var_locales   :   MARCA_INICIO_VAR {decVar = 1;} 
							Variables_locales 
							MARCA_FIN_VAR { decVar = 0;}
                        |   ;

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var 	;

Cuerpo_declar_var       :   tipo {getType($1);} linea_variables PYC
						|	error 	;

// Definido para no confundir con <Parametro>
tipo					:	TIPO {	temp=$1.tipo; $$.tipo=$1.tipo;	}
						| 	error 	;

linea_variables			:	linea_variables COMA variable
						|	variable 	;

variable 				:	ID 
							{
								if (decVar == 1)
								{
									$1.atrib = 0;
									TS_AddVar($1);
								}
								//else
								//	if (decParam == 0)
								//		TS_GetId($1, &$$);
							}		

							|	Array ;

Array 					: 	ID CORCHETE_IZQ expresion CORCHETE_DER 
							{
								if($3.tipo != entero)
			  					printf("[Linea %d] Error semántico: Tipo índice array incorrecto.\n",linea);

			  					else
			  					{
			  						if (decVar == 1)
									{
										dim1 = atoi($3.lexema);
										$1.atrib = 1;
										TS_AddVar($1);
									}
									
									//else
									//	if (decParam == 0)
									//		TS_GetId($1, &$$);
			  					}
							}

						|	ID CORCHETE_IZQ expresion COMA expresion 
							CORCHETE_DER
							{
								if($3.tipo != entero && $5.tipo != entero)
			  					printf("[Linea %d] Error semántico: Tipo índice array incorrecto.\n",linea);

			  					else
			  					{
			  						if (decVar == 1)
									{
										dim1 = atoi($3.lexema);
										dim2 = atoi($5.lexema);
										$1.atrib = 1;
										TS_AddVar($1);
									}
									
									//else
									//	if (decParam == 0)
									//		TS_GetId($1, &$$);
			  					}
							}	
						;

Identificadores		    :   Identificadores COMA ID
							{
								int pos = TS_FindByID($3);
								if(pos < 0)
									printf("[Linea %d] Error semántico: ID %s no declarada.\n",
									linea, $3.lexema);
							}
                        |   ID 
	                        {
								int pos = TS_FindByID($1);
								if(pos < 0)
									printf("[Linea %d] Error semántico: ID %s no declarada.\n",
									linea, $1.lexema);
							}
                        | 	error ;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog
						|	;

Declar_subprog          : 	PROCEDIMIENTO ID 
							{decParam = 1;} {TS_AddPROC($2);}
							PARENT_IZQ Parametros PARENT_DER 
							{decParam = 0;} {subProg = 1;} bloque {subProg = 0; } 	;

Parametros  			: 	Parametros COMA Parametro 
	        			| 	Parametro
	        			|
			   			| 	error ;

Parametro 				: 	tipo ID {getType($1); TS_AddParam($2);}
						
						|	tipo ID CORCHETE_IZQ CORCHETE_DER 
							{getType($1); TS_AddParam($2);}
						
						|	tipo ID CORCHETE_IZQ CORCHETE_DER
							CORCHETE_IZQ CORCHETE_DER 
							{getType($1);}{TS_AddParam($2);}
						;

Sentencias  			: 	Sentencias Sentencia
            			| 	Sentencia ;

Sentencia 			    :   bloque
						| 	sentencia_asignacion
						| 	sentencia_si
						| 	sentencia_mientras
						|	sentencia_hacer
						|	sentencia_entrada
						| 	sentencia_salida
						| 	llamada_proced 	;

sentencia_asignacion	:   Ide_exp OP_ASIG expresion PYC 
							{
								if (TSGetId($1) != $3.tipo)
								printf("[Linea %d] Error semántico: Asignación de tipos desiguales.\n",linea);
								
								else if(esArray($1) == 0 
								&& esArray($3) == 0)
								{
									int ret = checkDimensArray($1, $3);
									// Borrar arrayDePaso
									if(ret > 0)
										TS_DelEntry();
								}
							}
						;

Ide_exp 				:	ID { TS_GetId($1, &$$); }
						| 	Array_exp	;

Array_exp 				:	ID CORCHETE_IZQ expresion CORCHETE_DER
							{
								$$.tipo = $1.tipo;
								if($3.tipo != entero)
			  					printf("[Linea %d] Error semántico: Tipo índice array incorrecto.\n",linea);
							}
			  			
			  			|	ID CORCHETE_IZQ expresion COMA expresion 
			  				CORCHETE_DER
			  				{
			  					$$.tipo = $1.tipo;
			  					if($3.tipo != entero && $3.tipo!= $5.tipo)
			  					printf("[Linea %d] Error semántico: Tipo índice array incorrecto.\n",linea);
							}	;

sentencia_si			:   si
						|	si SINO Sentencia 	;

si 						:	SI PARENT_IZQ expresion
							{
								if($3.tipo != booleano)
								printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
							}
							PARENT_DER ENTONCES Sentencia 	
						;


sentencia_mientras		:   MIENTRAS PARENT_IZQ expresion 
							{
								if($3.tipo != booleano)
								printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
							}
							PARENT_DER Sentencia
						;

sentencia_hacer			:   HACER bloque HASTA PARENT_IZQ expresion 
							{
								if($5.tipo != booleano)
								printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
							}
							PARENT_DER PYC 
						;

sentencia_entrada 		: 	ENTRADA CADENA COMA Identificadores PYC	;

sentencia_salida 		: 	SALIDA lista_exp_cadena PYC	;

lista_exp_cadena 		: 	lista_exp_cadena COMA exp_cadena
						|	exp_cadena 	;

exp_cadena 				: 	expresion | CADENA 	;

llamada_proced		    :	cabecera_proc argumentos_proc PYC	
							{ checkparam = 0; }
						;

cabecera_proc   		: 	ID PARENT_IZQ 
							{
								checkProc = TS_FindByName($1);

								if(checkProc == -1) 	
	printf("[Linea %d] Error Semántico: Procedimiento %s no declarado.\n", linea, $1.lexema);
							}
						;

argumentos_proc 		:	expresiones PARENT_DER 
							{ TS_FunctionCall(&$$); }
                		| 	PARENT_DER 
                			{ TS_FunctionCall(&$$); }
                		;

expresiones				:	expresiones COMA expresion 
							{ TS_CheckParam($3); }
                        
                        |	expresion 
                        	{ TS_CheckParam($1); }
                        ;

expresion				:   PARENT_IZQ expresion 
							PARENT_DER 
						| 	ID {TS_GetId($1, &$$);}
                        | 	OP_NOT expresion
                        	{
                        		$$.tipo = desconocido;
                        		if($2.tipo != booleano)
                        			printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
                        		else $$.tipo = $2.tipo;
                        	}
						| 	MASMENOS expresion %prec OP_NOT
							{
								$$.tipo = desconocido;
								if($2.tipo != entero)
									printf("[Linea %d] Error semántico: Expresión no entera.\n", linea);
								else $$.tipo = $2.tipo;
							}
						| 	expresion OP_OR expresion
							{
								$$.tipo = desconocido;
								if($1.tipo != booleano && $1.tipo != $3.tipo)
                        			printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
                        		else $$.tipo = $1.tipo;
							}
						|	expresion OP_AND expresion
							{
								$$.tipo = desconocido;
								if($1.tipo != booleano && $1.tipo != $3.tipo)
                        			printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
                        		else $$.tipo = $1.tipo;
							}
						|	expresion OP_XOR expresion
							{
								$$.tipo = desconocido;
								if($1.tipo != booleano && $1.tipo != $3.tipo)
                        			printf("[Linea %d] Error semántico: Expresión no lógica.\n", linea);
                        		else $$.tipo = $1.tipo;
							}
						|	expresion OP_REL expresion
							{
								$$.tipo = desconocido;
								if($1.tipo != $3.tipo)
                        			printf("[Linea %d] Error semántico: Expresión no comparable.\n", linea);
                        		else $$.tipo = booleano;
                        		//printf("TIPO REL: %d\n", $$.tipo);
							}
						|	expresion OP_IGUALDAD expresion
							{
								$$.tipo = desconocido;
								if($1.tipo != $3.tipo)
                        			printf("[Linea %d] Error semántico: Expresiones de distinto tipo.\n", linea);
                        		else $$.tipo = booleano;
                        		//printf("TIPO IGUALDAD: %d\n", $$.tipo);
							}
						|	expresion OP_MULT expresion
							{
								$$.tipo = desconocido;

								if($1.tipo == $3.tipo)
                        		{
                        			if(esArray($1) == 0 && esArray($3) == 0)
									{									
										if($2.atrib == 2)
											checkMultArray($1, $3, &$$);
									}

									else $$.tipo = $1.tipo;
                        		}
                        		
                        		else 
                        			printf("[Linea %d] Error semántico: Expresiones de tipo inoperable.\n", linea);
							}
						| 	expresion MASMENOS expresion
							{
								$$.tipo = desconocido;
								if($1.tipo == $3.tipo)
                        			$$.tipo = $1.tipo;
                        		
                        		else 
                        			printf("[Linea %d] Error semántico: Expresiones de tipo inoperable.\n", linea);
                        		//printf("TIPO MASMENOS: %d\n", $$.tipo);
							}
						|	Array_exp {$$.tipo = $1.tipo;}
						| 	Constante 
							{$$.lexema = $1.lexema; $$.tipo = $1.tipo;}
//						|	Agregados
						| 	error	;

//Agregados 			:	INICIO_BLOQUE Argumentos FIN_BLOQUE	;
//						|	INICIO_BLOQUE Argumentos PYC
//							Argumentos FIN_BLOQUE ;

Constante				:   CONSTANTE 
							{$$.lexema = $1.lexema; $$.tipo = $1.tipo;} 
						
						| 	NATURAL	
							{$$.lexema = $1.lexema; $$.tipo = entero;}
						;

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
	fprintf(stderr,"[Linea %d] Error %i: %s\n", linea, error_sintactico, msg);
}
