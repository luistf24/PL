
#define MAX_TS 1000

unsigned int TOPE=0;
unsigned int Subprog;

typedef enum {marca, procedimiento, variable, parametro_formal} tipoEntrada;

typedef enum {entero, real, caracter, booleano, array, desconocido, no_asignado} dtipo;

typedef struct
{
	tipoEntrada 	entrada;
	char 			*nombre;
	dtipo 			tipoDato;
	unsigned int 	parametros;
	unsigned int 	dimensiones;
	int 			TamDimen1;
	int 			TamDimen2;
} entradaTS;

entradaTS TS[MAX_TS];

typedef struct
{
	int atrib;
	char *lexema;
	dtipo tipo;
} atributos;

#define YYSTYPE atributos 

//TS_InsertaMARCA() 
//TS_VaciarENTRADAS()
//TS_InsertaSUBPROG()
//TS_InsertaPARAMF()
