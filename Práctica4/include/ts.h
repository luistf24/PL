#define MAX_TS 1000

unsigned int TOPE=-1;
unsigned int Subprog;

typedef enum TIPO {marca, procedimiento, variable, parametro_formal, funcion, var_asignada, llamada_proc, compr_ambito} tipoEntrada;

typedef enum {entero, real, caracter, booleano, array, desconocido, no_asignado} dtipo;

typedef struct entradaTS
{
	tipoEntrada 	entrada;
	char 			*nombre;
	dtipo 			tipoDato;
	unsigned int 	parametros;
	unsigned int 	dimensiones;
	char* 			TamDimen1;
	char* 			TamDimen2;
} entradaTS;

entradaTS TS[MAX_TS];

typedef struct
{
	int atrib;
	char *lexema;
	dtipo tipo;
	int param;
	int dim;
} atributos;

#define YYSTYPE atributos

int TS_Inserta(entradaTS elem){

	TOPE+=1;
	TS[TOPE]=elem;

	//imprimir_tabla();
	return TOPE
}

int TS_VaciarEntrada(){
	if(TOPE>0) TOPE-=1;
	//imprimir_tabla();
	return TOPE;
}

int TS_VaciarBloque(){
	while(!comprobar_Entrada(marca, TOPE))  //Quito todas las entradas hasta llegar a la marca
		TS_VaciarEntrada();
	TS_VaciarEntrada();  //Quito la marca
	while (comprobar_Entrada(procedimiento, TOPE) || comprobar_Entrada(parametro_formal, TOPE)) //Quito los parametros y el procedimiento
		TS_VaciarEntrada();
	//imprimir_tabla();
	return TOPE;

}

int comprobar_Entrada(tipoEntrada tipo, int cont){
	int ret = 0;
	if (TS[cont].entrada==tipo)
		ret=1;
	return ret;
}

int buscar_repetido(tipoEntrada tipo, char *nom){
	int encontrado=0;
	unsigned int cont=TOPE;
	if (strcmp(nom,TS[cont].nombre)==0 && TS[cont].entrada==tipo) encontrado=1;
	while(encontrado==0 && comprobar_Entrada(marca, cont)==0){
		cont-=1;
		if (strcmp(nom,TS[cont].nombre)==0 && TS[cont].entrada==tipo)
			encontrado=1;

	}
	if (encontrado==0) cont=0;
	return cont;
}

int buscar_ambito(tipoEntrada tipo, char *nom){
	int encontrado = 0;
	unsigned int cont=TOPE;
	if (strcmp(nom,TS[cont].nombre)==0 && TS[cont].entrada==tipo) encontrado=1;
	while(encontrado==0 && cont != 0){
		cont-=1;
		if (strcmp(nom,TS[cont].nombre)==0 && TS[cont].entrada==tipo)
			encontrado=1;

	}
	if (encontrado==0) cont=0;
	return cont;
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
		case var_asignada:
			nombre="var_asignada";
			break;
		case llamada_proc:
			nombre="llamada_proc";
			break;
		case compr_ambito:
			nombre="compr_ambito";
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
	printf("%-5s%-20s%-25s%-20s%-10s%-5s%-10s%-10s\n", "Num", "TipoEnt", "Nombre", "TipoDato", "Parametros", "Dimension", "Tam1", "Tam2");

	for(int i=0; i<=TOPE;i++)
		printf("%-5i%-20s%-25s%-20s%-10i%-5i%-10s%-10s\n", i, getEntrada(TS[i].entrada), TS[i].nombre, getTipoDato(TS[i].tipoDato), TS[i].parametros, TS[i].dimensiones, TS[i].TamDimen1, TS[i].TamDimen2);
		//printf("%-5i%-20s%-25s\n", i, getEntrada(TS[i].entrada), TS[i].nombre);

	printf("\n");
	printf("\n");
	printf("-------------------------------------------------------------------------------------------------------");
	printf("\n");
	printf("\n");
}
