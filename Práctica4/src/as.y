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
dtipo temp=no_asignado;
FILE *fichero;

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

Principal             	:   PRINCIPAL {
																				fichero = fopen("Intermedio.c", "wt");
																				fputs("int main()", fichero);
																				}
																				bloque 	;

bloque 					:   INICIO_BLOQUE
							{
								tipoEntrada a=marca;
								dtipo b = desconocido;
								entradaTS marca = {.entrada=a, .nombre="marca", .tipoDato=b,
								.parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};

								TS_Inserta(marca);

								fputs("\n { \n\t\t", fichero);
							}

							Declar_de_var_locales
							{fputs("\n\n\t", fichero);}
							Declar_de_subprogs
							Resto_bloque	;

Resto_bloque			:	Sentencias
							FIN_BLOQUE { TS_VaciarBloque();
													fputs("}\n", fichero);
													}
						|	FIN_BLOQUE { TS_VaciarBloque();
												fputs("}\n", fichero);
												}	;

Declar_de_var_locales   :   MARCA_INICIO_VAR Variables_locales MARCA_FIN_VAR
                        |   ;

Variables_locales 	    :   Variables_locales Cuerpo_declar_var
						| 	Cuerpo_declar_var 	;

Cuerpo_declar_var       :   tipo linea_variables PYC
							{

								int variables=$2.param;
								int aux=variables;
								char *tipo=$1.lexema;
								if(strcmp($1.lexema, "nulo")!=0){
									for(int i=0; i<variables;i++)
										TS[TOPE-i].tipoDato=$1.tipo;

									fprintf(fichero, "%s ", tipo);
									while(variables>0)
									{
										imprimir_var(TS[TOPE-variables+1], fichero);
										if (variables>1) fprintf(fichero, ", ");

										variables=variables-1;
									}

									fprintf(fichero, "; \n \t");
								}
								else{
									for(int i=0; i<variables;i++)
										TS_VaciarEntrada();

								}
							}

						|	tipo linea_variables error 	{	int variables=$2.param;
																						for(int i=0; i<variables;i++)
																							TS_VaciarEntrada();
																					};



// Definido para no confundir con <Parametro>
tipo					:	TIPO {temp=$1.tipo; $$.tipo=$1.tipo;}
						| error  {printf("error semantico [Linea %d]: declaración incorrecta de tipo de variable \n",linea_actual);
											$$.lexema="nulo";}	;

linea_variables			:	linea_variables COMA variable {$$.param= $$.param+1;}
						|	variable {$$.param=1;}	;

variable 				:	ID {

											tipoEntrada a =variable;
											dtipo b= temp;
											entradaTS variable ={.entrada=a, .nombre=$1.lexema, .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
											int ind = buscar_repetido(a, $1.lexema); //busco si esta repetido

											tipoEntrada a2 = parametro_formal;
											int ind2 = buscar_ambito(a2, $1.lexema); //busco si hay un parametro formal con ese ID

											if (ind==0) {
												if(ind2==0)
													TS_Inserta(variable);   // No lo está, lo añado
												else
													printf("error semantico [Linea %d]: ya existe un parámetro %s en una funcion \n",linea_actual, $1.lexema);
											}
											else TS[ind]=variable;

											}

						| Array ;

Array 					: 	ID CORCHETE_IZQ expresion CORCHETE_DER {
																tipoEntrada a =variable;
																dtipo b= array;
																entradaTS variable ={.entrada=a, .nombre=$1.lexema, .tipoDato=b, .parametros=0, .dimensiones=1,.TamDimen1=$3.lexema,.TamDimen2="0"};
																int ind = buscar_repetido(a, $1.lexema); //busco si esta repetido

																tipoEntrada a2 = parametro_formal;
																int ind2 = buscar_ambito(a2,$1.lexema);

																if (ind==0){
																	if(ind2==0)
																		TS_Inserta(variable); // No lo está, lo añado
																	else
																		printf("error semantico [Linea %d]: ya existe un parámetro %s en una funcion \n",linea_actual, $1.lexema);
																}
																else TS[ind]=variable;
						}

						|	ID CORCHETE_IZQ expresion COMA expresion CORCHETE_DER {
																tipoEntrada a =variable;
																dtipo b= array;
																entradaTS variable ={.entrada=a, .nombre=$1.lexema, .tipoDato=b, .parametros=0, .dimensiones=2, .TamDimen1=$3.lexema, .TamDimen2=$5.lexema};
																int ind = buscar_repetido(a, $1.lexema); //busco si esta repetido

																tipoEntrada a2 = parametro_formal;
																int ind2 = buscar_ambito(a2,$1.lexema);

																if (ind==0){
																	if(ind2==0)
																		TS_Inserta(variable); // No lo está, lo añado
																	else
																		printf("error semantico [Linea %d]: ya existe un parámetro %s en una funcion \n",linea_actual, $1.lexema);
																}
																else
																	TS[ind]=variable;
							};

Identificadores		    :   Identificadores COMA ID
                        |   ID
                        | 	error ;

Declar_de_subprogs 	    :   Declar_de_subprogs Declar_subprog
						|	;

Declar_subprog          : 	PROCEDIMIENTO ID
							{
								tipoEntrada a = procedimiento;
								dtipo b = desconocido;
								entradaTS procedimiento = {.entrada=a, .nombre=yylval.lexema,
								.tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
								TS_Inserta(procedimiento);

							}

							PARENT_IZQ Parametros
							{
								int ind = buscar_repetido(procedimiento, $2.lexema);
								TS[ind].parametros=$5.param;
							}

							PARENT_DER {
							int parametros = $5.param;
							dtipo tipos[parametros];
							char *nombres[parametros];
							fprintf(fichero, "int %s()", $2.lexema);

							}	 bloque

							;

Parametros			    :	Parametros COMA Parametro  {$$.param=1 +  $1.param + $2.param;}
                        | 	Parametro  {$$.param=1+$1.param;}
                        |	{$$.param=0;};

Parametro				:   TIPO ID
							{
								entradaTS param_form = {.entrada=parametro_formal,
								.nombre=$2.lexema	, .tipoDato = $1.tipo, .parametros=0,.
								dimensiones=0, .TamDimen1="0",	.TamDimen2="0"};

								TS_Inserta(param_form);
							}

						|	TIPO ID CORCHETE_IZQ CORCHETE_DER
							{
								entradaTS param_form = {.entrada=parametro_formal,
								.nombre=$2.lexema, .tipoDato = $1.tipo, .parametros=0,
								.dimensiones=1, .TamDimen1="desc", .TamDimen2="desc"};

								TS_Inserta(param_form);
							}

						|	TIPO ID CORCHETE_IZQ CORCHETE_DER
							CORCHETE_IZQ CORCHETE_DER
							{
								entradaTS param_form = {.entrada=parametro_formal,
								.nombre=$2.lexema, .tipoDato = $1.tipo, .parametros=0,
								.dimensiones=2, .TamDimen1="desc", .TamDimen2="desc"};

								TS_Inserta(param_form);
							}

						|	error	;

Sentencias 			    :   Sentencias Sentencia
						| 	Sentencia 	;

Sentencia 			    :   bloque
						| 	sentencia_asignacion {fprintf(fichero, "%s; \n",$1.codigo);}
						| 	sentencia_si
						| 	sentencia_mientras
						|	sentencia_hacer
						|	sentencia_entrada
						| 	sentencia_salida
						| 	llamada_proced 	;

sentencia_asignacion	:   Ide_exp OP_ASIG expresion PYC {
								entradaTS asignacion = {.entrada=var_asignada, .nombre=$1.lexema, .tipoDato = desconocido, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
								if($1.tipo == $3.tipo){
									$$.tipo = $3.tipo;
									asignacion.tipoDato=$3.tipo;
								}else{
									printf("error semantico [Linea %d]: intento de asignación entre tipos distintos",linea_actual);
								}
								char codigo[255];
								strcpy(codigo, $1.lexema);
								strcat(codigo, "=");
								strcat(codigo, $3.lexema);
								strcat(codigo, $3.codigo);
								$$.codigo=codigo;


							} ;

Ide_exp 				:	ID
							{
								$$.tipo = $1.tipo;

								$$.lexema=$1.lexema;
								tipoEntrada a1 = variable;
								tipoEntrada a2 = parametro_formal;

								entradaTS comprob_ambito = {.entrada=compr_ambito,
								.nombre=$1.lexema, .tipoDato=$1.tipo, .parametros=0,
								.dimensiones=0, .TamDimen1="0", .TamDimen2="0"};

								int ind1 = buscar_ambito(a1,$1.lexema);
								int ind2 = buscar_ambito(a2,$1.lexema);

								if(ind1 != 0 || ind2 != 0)
								    printf(" ");
								//	TS_Inserta(comprob_ambito);
								else{
									printf("error_semantico %i: variable %s usada fuera de ambito \n",linea_actual, $1.lexema);
								}
								$$.codigo="";
								$$.lugar=$1.lugar; //TODO meter lugares en .l
							}

						| 	Array_exp 	{$$.tipo = $1.tipo;};


Array_exp 				:	ID CORCHETE_IZQ expresion CORCHETE_DER
							{
								$$.tipo = $1.tipo;
								tipoEntrada a1 = variable;
								tipoEntrada a2 = parametro_formal;

								if($3.tipo != entero)
									printf("error semantico [Linea %d]: tipo de dato para indice erroneo, se espera entero \n",linea_actual);

								entradaTS comprob_ambito = {.entrada=compr_ambito, .nombre=$1.lexema,
								.tipoDato=array, .parametros=0, .dimensiones=0,
								.TamDimen1="0", .TamDimen2="0"};

								int ind1 = buscar_ambito(a1,$1.lexema);
								int ind2 = buscar_ambito(a2,$1.lexema);

								if(ind1 != 0 || ind2 != 0)
										printf(" ");
							//		TS_Inserta(comprob_ambito);
								else{
									printf("error_semantico %i : variable %s usada fuera de ambito \n",linea_actual, $1.lexema);
								}
								$$.codigo="";
								$$.lugar=$1.lugar;
							}

			  			|	ID CORCHETE_IZQ expresion COMA expresion CORCHETE_DER
			  				{
			  					$$.tipo = $1.tipo;
									$$.codigo="";
									$$.lugar=$1.lugar;
							}	;

sentencia_si			:   si
						|	si SINO Sentencia 	;

si 						:	SI PARENT_IZQ expresion PARENT_DER ENTONCES Sentencia {if($3.tipo != booleano)
																					printf("error semantico [Linea %d]: la expresion condicional no es de tipo booleano \n",linea_actual);
																					}	;

sentencia_mientras		:   MIENTRAS PARENT_IZQ expresion PARENT_DER Sentencia {if($3.tipo != booleano)
																				printf("error semantico [Linea %d]: la expresion condicional no es de tipo booleano \n",linea_actual);
																				}	;

sentencia_hacer			:   HACER bloque HASTA PARENT_IZQ expresion PARENT_DER PYC {if($5.tipo != booleano)
																					printf("error semantico [Linea %d]: la expresion condicional no es de tipo booleano \n",linea_actual);
																					}	;

sentencia_entrada 		: 	ENTRADA Identificadores PYC	;

sentencia_salida 		: 	SALIDA lista_exp_cadena PYC {fprintf(fichero, "printf(\" %s \"); \n", $2.codigo);}	;

lista_exp_cadena 		: 	lista_exp_cadena COMA exp_cadena{
																													char codigo[300];
																													strcpy(codigo, $3.codigo);
																													strcat(codigo, $1.codigo);
																													$$.codigo=codigo;
																												}
						|	exp_cadena {char buffer[255];
													strcpy(buffer, $1.codigo);
													$$.codigo=buffer;
													}	;

exp_cadena 				: 	expresion {$$.codigo=$1.codigo;}| CADENA {char buffer[255];
																																strcpy(buffer, $1.lexema);
																																$$.codigo=buffer;
																																}	;

llamada_proced		    :   ID PARENT_IZQ argumentos PARENT_DER PYC {
																	tipoEntrada a_buscar = procedimiento;
																	tipoEntrada a = llamada_proc;
																	dtipo b = desconocido;
																	entradaTS llama_proc ={.entrada=a, .nombre=$1.lexema, .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
																	int ind = buscar_repetido(a_buscar,$1.lexema);
																	if(ind!=0){
																		if(TS[ind].parametros == $3.param){
																			int contador = 0;
																			int tip_correcto = 1;
																			tipoEntrada c = parametro_formal;
																			int ind2 = buscar_repetido(a_buscar,$1.lexema);

																			while(contador < $3.param && tip_correcto==1){
																				//printf("%s || %s tip_corr: %i\n", TS[ind2+contador+1].nombre, TS[TOPE-$3.param+1+contador].nombre, tip_correcto);
																				if(TS[ind2+contador].tipoDato == TS[TOPE-$3.param+contador].tipoDato){
																					tip_correcto=1;
																				}
																				else
																					tip_correcto=0;
																				contador++;
																			}
																			if(tip_correcto==1)
																				TS_Inserta(llama_proc);
																			else
																				printf("error semantico [Linea %d]: el tipo de los parametros de la llamada a función no coincide con la cabecera \n",linea_actual);
																		}
																		else
																			printf("error Semántico [Linea %d]: llamada a funcion %s con numero incorrecto de argumentos \n",linea_actual, $1.lexema);
																	}else{
																		printf("error semántico [Linea %d]: llamada a función %s fuera de su ambito \n",linea_actual, $1.lexema);
																	}

																}
						|	ID PARENT_IZQ PARENT_DER PYC {tipoEntrada a_buscar = procedimiento;
																	tipoEntrada a = llamada_proc;
																	dtipo b = desconocido;
																	entradaTS llama_proc ={.entrada=a, .nombre=$1.lexema, .tipoDato=b, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
																	int ind = buscar_ambito(a_buscar,$1.lexema);
																	if(ind!=0){
																		if(TS[ind].parametros == 0)
																			TS_Inserta(llama_proc);
																		else
																			printf("error Semántico %i : llamada a funcion %s con numero incorrecto de argumentos \n",linea_actual, $1.lexema);
																	}else{
																		printf("error semántico %i : llamada a función %s fuera de su ambito \n",linea_actual,$1.lexema);
																	}
																}
						|   error   ;

argumentos              :   argumentos COMA expresion {$$.param = 1 + $1.param + $3.param;}
                        |   expresion {$$.param = 1 + $1.param;}	;

expresion				:   PARENT_IZQ expresion PARENT_DER {$$.tipo = $2.tipo;}
						| 	ID
							{


								$$.lexema=$1.lexema;
								$$.tipo=$1.tipo;
								tipoEntrada a1 = variable;
								tipoEntrada a2 = parametro_formal;
								entradaTS comprob_ambito = {.entrada=compr_ambito, .nombre=$1.lexema, .tipoDato=$1.tipo, .parametros=0, .dimensiones=0, .TamDimen1="0", .TamDimen2="0"};
								int ind1 = buscar_ambito(a1,$1.lexema);
								int ind2 = buscar_ambito(a2,$1.lexema);
								if(ind1 != 0 || ind2 != 0){
									if(ind1!=0)
										comprob_ambito.tipoDato = TS[ind1].tipoDato;
									else if(ind2!=0)
										comprob_ambito.tipoDato = TS[ind2].tipoDato;
								//	TS_Inserta(comprob_ambito);
								}
								else{
									printf("error_semantico [Linea %i]: variable %s usada fuera de ambito \n",linea_actual, $1.lexema);
								}
								$$.codigo=" ";
							}
						| 	Constante {$$.lexema=$1.lexema;
									   $$.tipo=yylval.tipo;
										 $$.codigo="";
										 }
                        | 	OP_NOT expresion {
												if($2.tipo != booleano){
													printf("error semantico [Linea %d]: la expresion (%s) no es de tipo booleano \n",linea_actual,$2.lexema);
												}
												$$.codigo=" ";
											 }
						| 	MASMENOS expresion {
												if($2.tipo == entero)
													$$.tipo = entero;
												else if($2.tipo == real)
													$$.tipo = real;
												else
													printf("error semantico [Linea %d]: la expresion (%s) debe ser numerica \n",linea_actual, $2.lexema);
												$$.codigo=" ";
											   }
						| 	expresion OP_OR expresion {
														if($1.tipo!=$3.tipo)
															printf("error_semantico[Linea %d]: comparación de tipos distintos \n",linea_actual);
													   	else{
														    if($1.tipo == booleano){
																$$.tipo = $1.tipo;
															}
															else
																printf("error semantico [Linea %d]: las expresiones deben ser booleanas \n",linea_actual);
														}
														$$.codigo=" ";
													   }
						|	expresion OP_AND expresion {
														if($1.tipo != $3.tipo)
															printf("error semantico [Linea %d]: comparación de tipos distintos \n",linea_actual);
														else{
															if($1.tipo == booleano){
																$$.tipo = $1.tipo;
															}
															else
																printf("error semantico [Linea %d]: las expresiones comparadas deben ser booleanas \n",linea_actual);
														}
														$$.codigo=" ";
													   }
						|	expresion OP_XOR expresion {
														if($1.tipo != $3.tipo)
															printf("error semantico [Linea %d]: comparación de tipos distintos \n",linea_actual);
														else{
															if($1.tipo == booleano){
																$$.tipo = $1.tipo;
															}
															else
																printf("error semantico [Linea %d]: las expresiones comparadas deben ser booleanas \n",linea_actual);
														}
														$$.codigo=" ";
													   }
						|	expresion OP_REL expresion {if($1.tipo != $3.tipo)
															printf("error semantico [Linea %d]: comparación de tipos distintos \n",linea_actual);
														else{
															if($1.tipo == entero || $1.tipo == real){
																$$.tipo = booleano;
															}else{
																printf("error semantico [Linea %d]: las expresiones comparadas deben ser cifras \n",linea_actual);
															}
														}
														$$.codigo=" ";
														}
						|	expresion OP_IGUALDAD expresion {


																if($1.tipo != $3.tipo)
																	printf("error semantico[Linea %d]: comparación de tipos 	distintos \n",linea_actual);
																else{
																	if($1.tipo == entero || $1.tipo == real){
																		$$.tipo = booleano;
																	}
																	else{
																		printf("error semantico [Linea %d]: las expresiones %s y %s deben ser numeros \n",linea_actual, $1.lexema, $3.lexema);
																	//	printf("ahora mismo son de tipo %s y %s \n",$1.tipo,$3.tipo);
																	}
																}
																$$.codigo=" ";
															}
						|	expresion OP_MULT expresion {

															if($1.tipo != $3.tipo)
																printf("error semantico[Linea %i]: multiplicación de tipos 	distintos \n",linea_actual);

															else{
																if($1.tipo == array){
																	int pos1 = buscar_ambito(variable,$1.lexema);
																	int pos2 = buscar_ambito(variable,$3.lexema);
																	if(TS[pos1].TamDimen2 != TS[pos2].TamDimen1)
																		printf("Las dimensiones de las matrices no concuerdan \n");
																}
															}
															$$.codigo=" ";
														}
						| 	expresion MASMENOS expresion {


															if($1.tipo != $3.tipo)
																printf("error semantico [Linea %d]: comparación de tipos 	distintos \n",linea_actual);
															else{
																if($1.tipo == entero || $1.tipo == real)
																	$$.tipo = $1.tipo;
																else{
																	printf("error semantico [Linea %d]: las expresiones %s y %s deben ser numeros \n",linea_actual, $1.lexema, $3.lexema);
																	//printf("ahora mismo son de tipo %s y %s \n",$1.tipo,$3.tipo);
																}
															}
															$$.codigo=" ";
														 }
						|	Array_exp
						|	Agregados
						| 	error	{ };

Agregados 				:	INICIO_BLOQUE argumentos FIN_BLOQUE	;
						|	INICIO_BLOQUE argumentos PYC
							argumentos FIN_BLOQUE ;

Constante				:   CONSTANTE
							{
								$$.lexema=$1.lexema;
								if($1.lexema=="verdadero" || $1.lexema=="falso")
									$$.tipo=booleano;
								else if($1.tipo==caracter)
									$$.tipo=caracter;
								else if($1.tipo==real)
									$$.tipo=real;
								else
									$$.tipo=caracter;
							}

						| 	NATURAL	{$$.lexema=yylval.lexema;
									 $$.tipo=entero;}	;

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
