#define MAX_TS 1000

unsigned int TOPE=0;
unsigned int Subprog;

typedef enum TIPO {marca, procedimiento, variable, parametro_formal, funcion} tipoEntrada;

typedef enum {entero, real, caracter, booleano, array, desconocido, no_asignado} dtipo;

typedef struct entradaTS
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
	TS[TOPE]=elem;
	
	imprimir_tabla();	
}

int TS_VaciarEntrada(){
	TOPE-=1;
	return TOPE;
}

int TS_VaciarBloque(){
	while(!comprobar_Entrada(marca))
		TS_VaciarEntrada();
	return TOPE;
	imprimir_tabla();
}

int comprobar_Entrada(tipoEntrada tipo){
	int ret = 0;
	if (TS[TOPE].entrada==tipo)
		ret=1;
	return ret;
}

//0= false
int buscar_repetido(tipoEntrada tipo, char *nom){
	int encontrado=0;
	unsigned int tope_orig=TOPE;
	while(!encontrado && !comprobar_Entrada(marca)){
		TOPE-=1;
		if (TS[TOPE].nombre==nom)
			encontrado==1;
	}
	TOPE=tope_orig;
	return encontrado;
}


void imprimir_tabla(){
	printf("%-5s%-20s%-25s%-20s%-10s%-5s%-5s%-5s\n", "Num", "TipoEnt", "Nombre", "TipoDato", "Parametros", "Dimension", "Tam1", "Tam2");
	
	for(int i=0; i<=TOPE;i++)
		//printf("%-5s%-20s%-25s%-20s%-10s%-5s%-5s%-5s\n", i, TS[i].entrada, TS[i].nombre, TS[i].tipoDato, TS[i].parametros, TS[i].dimensiones, TS[i].TamDimen1, TS[i].TamDimen2);
	printf("\n");
	printf("\n");
	printf("-------------------------------------------------------------------------------------------------------");
	printf("\n");
	printf("\n");
}
