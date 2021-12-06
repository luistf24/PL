#define MAX_TS 1000

unsigned int TOPE=-1;
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
	int param;
} atributos;

#define YYSTYPE atributos

int TS_Inserta(entradaTS elem){

	TOPE+=1;
	TS[TOPE]=elem;

	imprimir_tabla();
}

int TS_VaciarEntrada(){
	if(TOPE>0) TOPE-=1;
	imprimir_tabla();
	return TOPE;
}

int TS_VaciarBloque(){
	while(!comprobar_Entrada(marca))  //Quito todas las entradas hasta llegar a la marca
		TS_VaciarEntrada();
	TS_VaciarEntrada();  //Quito la marca
	while (comprobar_Entrada(procedimiento) || comprobar_Entrada(parametro_formal)) //Quito los parametros y el procedimiento
		TS_VaciarEntrada();
	//imprimir_tabla();
	return TOPE;

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

char *getEntrada( tipoEntrada tipo)
{
	char *nombre;
	switch (tipo){
		case marca:
			nombre="marca";
			break;
		case procedimiento:
			nombre="procedimiento";
			break;
		case variable:
			nombre="variable";
			break;
		case parametro_formal:
			nombre="parametro_formal";
			break;
		case funcion:
			nombre="funcion";
			break;
		default:
			nombre="ninguno";
		}
	return nombre;
}

char *getTipoDato(dtipo tipo)
{
	char *nombre;
	switch (tipo){
		case entero:
			nombre="entero";
			break;
		case real:
			nombre="real";
			break;
		case caracter:
			nombre="caracter";
			break;
		case booleano:
			nombre="booleano";
			break;
		case array:
			nombre="array";
			break;
		case no_asignado:
			nombre="no_asignado";
			break;
		default:
			nombre="desconocido";
		}
	return nombre;
}

void imprimir_tabla(){
	printf("%-5s%-20s%-25s%-20s%-10s%-5s%-5s%-5s\n", "Num", "TipoEnt", "Nombre", "TipoDato", "Parametros", "Dimension", "Tam1", "Tam2");

	for(int i=0; i<=TOPE;i++)
		printf("%-5i%-20s%-25s%-20s%-10i%-5i%-5i%-5i\n", i, getEntrada(TS[i].entrada), TS[i].nombre, getTipoDato(TS[i].tipoDato), TS[i].parametros, TS[i].dimensiones, TS[i].TamDimen1, TS[i].TamDimen2);
		//printf("%-5i%-20s%-25s\n", i, getEntrada(TS[i].entrada), TS[i].nombre);

	printf("\n");
	printf("\n");
	printf("-------------------------------------------------------------------------------------------------------");
	printf("\n");
	printf("\n");
}
