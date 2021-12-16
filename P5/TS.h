#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TS 1000

extern long TOPE;
extern unsigned int subProg;
extern int dim1, dim2;
extern unsigned int N;
typedef enum {
	marca, 
	procedimiento, 
	variable, 
	parametro_formal,
} tipoEntrada;

typedef enum {
	entero, 
	real, 
	caracter, 
	booleano,
	array_int,
	array_double,
	array_char,
	array_bool, 
	desconocido, 
	no_asignado
} dtipo;

typedef struct entradaTS
{
	tipoEntrada 	entrada;
	char 			*nombre;
	dtipo 			tipoDato;
	int 			finalizado;
	unsigned int 	parametros;
	unsigned int 	dimensiones;
	int 			TamDimen1;
	int				TamDimen2;
} entradaTS;

#define YYSTYPE atributos

typedef struct
{
	int atrib;
	char *lexema;
	dtipo tipo;
	int param;
	int dim;
	char *lugar;
	char *codigo;
} atributos;

// VARIABLES
extern entradaTS TS[MAX_TS];
// Línea del fichero que se está analizando
extern int linea;
// Inicio declaración de variables
extern int decVar;
// Inicio de una declaración de parámetros formales
extern int decParam;

// Inicio del cuerpo de un procedimiento
extern int esProc;

// Variable global que almacena el tipo de dato mas reciente
// en declaraciones
extern dtipo TipoTmp;

// Parámetros de definición de procedimiento
extern int nParams;

// Parámetros de llamada a un procedimiento
extern int checkparam;

// Variable con el nombre del procedimiento que se quiere comprobar
extern int checkProc;

// Índice en TS del procedimiento utilizado
extern int currentFunction;

//Funcion temporal
char *temporal();

// FUNCIONES TS

void getType(atributos value);

/* Inserta una entrada en la tabla de símbolos (TS). Devuelve 1 si funciona correctamente, -1 en caso de error */
int TS_AddEntry(entradaTS entrada);

/* Elimina una entrada en la tabla de símbolos (TS). Devuelve 1 si funciona correctamente, -1 en caso de error */
int TS_DelEntry();

/* Elimina todas las entradas de la tabla de símbolos del bloque actual y la cabecera del mismo si la tiene. Debe ser llamada al final de cada bloque. Devuelve 1 si funciona correctamente, -1 en caso de error */
int TS_CleanBlock();

void updateCurrentFunction(int lastFunc);

// Busca una entrada en la TS de una VARIABLE por su identificador. 
// Devuelve el índice de la entrada encontrada o -1 en caso de no encontrarla.
int TS_FindByID(atributos e);

// Busca una entrada en la TS de un PROCEDIMIENTO por su nombre. 
// Devuelve el índice de la entrada encontrada o -1 en caso de no encontrarla.
int TS_FindByName(atributos e);

// Inserta una entrada en la tabla de símbolos de una función o un bloque
void TS_AddMark();

// Añade una entrada en la tabla de símbolos de una variable local.
void TS_AddVar(atributos e);

// Inserta una entrada en TS de procedimiento.
void TS_AddPROC(atributos e);

// Inserta una entrada en la tabla de símbolos de un parámetro formal o argumento.
void TS_AddParam(atributos e);

// FUNCIONES SEMÁNTICO
// Devuelve el identificador
void TS_GetId(atributos id, atributos* res);
int TSGetId(atributos id);

// Realiza la comprobación de la llamada a una función
void TS_FunctionCall(atributos* res);

// Realiza la comprobación de cada parámetro de una función
void TS_CheckParam(atributos param);

// Comprueba si un atributo es un array
int esArray(atributos e);

// Comprueba las dimensiones de dos arrays
int checkDimensArray(atributos a, atributos b);
// Comprueba multiplicacion de arrays
void checkMultArray(atributos a, atributos b, atributos *res);
// Comprueba arrays y tipos básicos
int checkTipoArray(dtipo a);
// Comprueba indices de un array
int checkIndexArray(int size, atributos b);

// Muestra por pantalla las entradas de la tabla de símbolos
void printTS();

// Muestra por pantalla un atributo recibido
void printAttr(atributos e, char *msg);

// FUNCIONES VISUALIZAR TS
char *getEntrada( tipoEntrada tipo);
char *getTipoDato(dtipo tipo);
void imprimir_tabla();

int imprimir_var(entradaTS elem, FILE *fichero);


