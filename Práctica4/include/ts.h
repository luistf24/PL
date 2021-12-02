#define MAX_TS 1000

unsigned int TOPE=0;
unsigned int Subprog;

typedef enum {marca, procedimiento, variable, parametro_formal, funcion} tipoEntrada;

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

int TS_Inserta(entradaTS elem){
	TOPE+=1;
	TS[MAX_TS]=elem;
}

int TS_VaciarEntrada(){
	TOPE-=1;
	return TOPE;
}

int TS_VaciarBloque(){
	while(!comprobar_Entrada(marca))
		TS_VaciarEntrada();
	return TOPE;
}

bool comprobar_Entrada(tipoEntrada tipo){
	bool ret = false;
	if TS[TOPE].tipoEntrada==tipo
		ret=true;
	return ret;
}

bool buscar_repetido(tipoEntrada tipo, char *nom){
	bool encontrado=false;
	unsigned int tope_orig=TOPE;
	while(!encontrado && !comprobar_Entrada(marca)){
		TOPE-=1
		if (TS[TOPE].nombre==nom)
			encontrado==true;
	}
	TOPE=tope_orig;
	return encontrado;
}
