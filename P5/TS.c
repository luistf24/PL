#include "TS.h"

entradaTS TS[MAX_TS] ;

long int TOPE = 0;
unsigned int subProg = 0;
unsigned int N = 0;
int dim1 = 0;
int dim2 = 0;
int linea = 1;
int decVar = 0;					
int decParam = 0;											
dtipo TipoTmp = no_asignado;
int nParams = 0;
int checkparam = 0;
int checkProc = 0;
int currentFunction = -1;


char *temporal(){
	char num = N + '0';
	N=N+1;
	char *ret;
	strcpy(ret, "temp");
	strcat(ret, num);
	return ret;
}

void getType(atributos value)
{
	TipoTmp = value.tipo;
}

int TS_AddEntry(entradaTS entrada)
{
	if(TOPE < MAX_TS) 
	{
		TS[TOPE].entrada 		= entrada.entrada;
		TS[TOPE].nombre			= entrada.nombre;
		TS[TOPE].tipoDato 	= entrada.tipoDato;
		TS[TOPE].finalizado = 0;
		TS[TOPE].parametros = entrada.parametros;
		TS[TOPE].dimensiones = entrada.dimensiones;
		TS[TOPE].TamDimen1 = entrada.TamDimen1;
		TS[TOPE].TamDimen2 = entrada.TamDimen2;

		TOPE++;

		return 1;
	}

	else
	{
		printf("[Linea %d] ERROR: (TS) OVERFLOW", linea);
		return -1;
	}
}

int TS_DelEntry()
{
	if(TOPE >= 0)
	{
		TOPE--;

		return 1;
	}

	else
	{
		printf("[Linea %d] ERROR: (TS) EMPTY", linea);
		return -1;
	}
}

// Se llama al final de cada bloque
int TS_CleanBlock()
{
	int ret = -1;
	int actualTOPE = -1;

	if (TOPE == 0)
		return 1;

	int _continue = 1;
	while(TOPE > 0 && _continue > 0)
	{
		TOPE--;

		if (TS[TOPE].entrada == marca)
		{
			ret = 1;
			_continue = 0;
		}
	}

	if (TOPE == 0)	return ret;
	
	actualTOPE = TOPE;
	actualTOPE--;
	if (TS[actualTOPE].entrada == parametro_formal )
	{			
		while (TS[actualTOPE].entrada == parametro_formal)
			actualTOPE--;
	}
	
	if (TS[actualTOPE].entrada == procedimiento)
	{
		TS[actualTOPE].finalizado = 1;
		updateCurrentFunction(actualTOPE);
	}

	return ret;
}

void updateCurrentFunction(int lastFunc)
{
	lastFunc--;
	while (TS[lastFunc].entrada != procedimiento && lastFunc > 0)
		lastFunc--;

	if (lastFunc == 0)
		currentFunction = -1;
	
	else
	{
		if (TS[lastFunc].finalizado == 0)
			currentFunction = lastFunc;
		
		else updateCurrentFunction(lastFunc);
	}
}

int TS_FindByID(atributos e)
{
	int i = TOPE - 1;
	int found = 0;

	if (TOPE == 0)
		return -1;

	while (i > 0 && found == 0) 
	{
		if (TS[i].entrada == variable 
			&& strcmp(e.lexema, TS[i].nombre) == 0)
		{
			found = 1;
			break;
		}

		i--;
	}

	if(found == 0) 	return -1;
	else			return i;
}

int TS_FindByName(atributos e)
{
	int i = TOPE - 1;
	int found = 0;

	if (TOPE == 0)
		return -1;

	while (i > 0 && found == 0) 
	{
		if (TS[i].entrada == procedimiento 
			&& strcmp(e.lexema, TS[i].nombre) == 0){
			found = 1;
			break;
		}

		i--;
	}

	if(found == 0)	return -1;
	else			return i;
}

void TS_AddMark()
{
	entradaTS initBlock;
	initBlock.entrada = marca;
	initBlock.nombre = "{";
	initBlock.tipoDato = no_asignado;
	initBlock.finalizado = 0;
	initBlock.parametros = 0;
	initBlock.dimensiones = 0;
	initBlock.TamDimen1 = 0;
	initBlock.TamDimen2 = 0;

	TS_AddEntry(initBlock);

	// Añadir parámetros de procedemiento como Var_locales
	if(subProg == 1)
	{
		int j = TOPE - 2;
		while(j > 0 && TS[j].entrada == parametro_formal)
		{
			entradaTS Param;
			Param.entrada 		= variable;
			Param.nombre 			= TS[j].nombre;
			Param.tipoDato 		= TS[j].tipoDato;
			Param.parametros 	= TS[j].parametros;
			Param.dimensiones = TS[j].dimensiones;
			Param.TamDimen1 	= TS[j].TamDimen1;
			Param.TamDimen2 	= TS[j].TamDimen2;
			TS_AddEntry(Param);
			j--;
		}
	}
}

void TS_AddVar(atributos e)
{
	int j = TOPE-1;
	int found = 0;
	int index;

	int numparams = TS[currentFunction].parametros;

	for (index = currentFunction+1; index < currentFunction+1 + numparams; index++)
	{
		if (strcmp(TS[index].nombre, e.lexema) == 0)
		{
			printf("[Linea %d] ERROR DE DECLARACIÓN: ID existente: %s\n", 
				linea, e.lexema);
			return;
		}
	}

	if(j >= 0 && decVar == 1)
	{
		// Buscar marca de bloque
		while( TS[j].entrada != marca && j >= 0 
				&& found == 0)
		{
			if(strcmp(TS[j].nombre, e.lexema) != 0)
				j--;
			
			else
			{
				found = 1;
				printf("[Linea %d] ERROR DE DECLARACIÓN: ID existente: %s\n",
					linea, e.lexema);
				return;
			}
		}

		entradaTS newIn;
		newIn.entrada = variable;
		newIn.nombre = e.lexema;
		newIn.tipoDato = e.tipo;
		newIn.parametros = 0;
		newIn.TamDimen1 = 0;
		newIn.TamDimen2 = 0;
		newIn.dimensiones = 0;
		if(dim1 > 0)
		{
			newIn.TamDimen1 = dim1;
			++newIn.dimensiones;
		}	
		
		if(dim2 > 0)
		{
			newIn.TamDimen2 = dim2;
			++newIn.dimensiones;
		}
		
		// Tipo Array
		if(e.atrib == 1)
		{
			if(e.tipo == entero)
				newIn.tipoDato = array_int;
			else if(e.tipo == real)
				newIn.tipoDato = array_double;
			else if(e.tipo == caracter)
				newIn.tipoDato = array_char;
			else
				newIn.tipoDato = array_bool;

			dim1 = 0; dim2 = 0;
		}

		TS_AddEntry(newIn);
	}
}

void TS_AddPROC(atributos e)
{
	int index = TS_FindByName(e);
	if(index > 0)
	{
		printf("[Linea %d] Error Semántico: Procedimiento duplicado %s\n",
		linea, TS[index].nombre);
		return;
	}

	entradaTS proc;
	proc.entrada 	= procedimiento;
	proc.nombre 	= e.lexema;
	proc.tipoDato 	= e.tipo;
	proc.parametros = 0;
	
	proc.dimensiones = 0;
	proc.TamDimen1 = 0;
	proc.TamDimen2 = 0;
	proc.dimensiones = 0;

	currentFunction = TOPE;

	TS_AddEntry(proc);
}

void TS_AddParam(atributos e)
{
  int j = TOPE - 1, found = 0;
	while( j != currentFunction && found == 0 )
	{
		if(strcmp(TS[j].nombre, e.lexema) != 0)
			j--;
		else
		{
			found = 1;
			printf("[Linea %d] ERROR DE DECLARACIÓN: Parámetro duplicado.%s\n",
			 linea, e.lexema);
		}
	}

	if(found == 0) 
	{
		entradaTS newIn;
		newIn.entrada = parametro_formal;
		newIn.nombre = e.lexema;
		newIn.tipoDato = TipoTmp;
		
		newIn.parametros = 0;
		newIn.TamDimen1 = dim1;
		if(dim1 > 0)
			newIn.dimensiones = 1;
		newIn.TamDimen2 = dim2;
		if(dim2 > 0)
			++newIn.dimensiones;
		else
			newIn.dimensiones = 0;
		TS_AddEntry(newIn);

		if (currentFunction > -1) 
			TS[currentFunction].parametros += 1;
	}
}

void TS_GetId(atributos id, atributos* res)
{
	int index = TS_FindByID(id);
	
	if(index == -1)
		printf("[Linea %d] ERROR BÚSQUEDA: ID %s no encontrada.\n", 
			linea, id.lexema);
	
	else 
	{
		res->lexema = strdup(TS[index].nombre);
		res->tipo = TS[index].tipoDato;
	}
}

int TSGetId(atributos id)
{
	int index = TS_FindByID(id);
	if(index == -1) 
	{
		//printf("%s %i\n", id.lexema, id.tipo);
		printf("[Linea %d] ERROR BÚSQUEDA: ID %s no encontrada.\n", 
			linea, id.lexema);
		return -1;
	}
	
	return TS[index].tipoDato;
}

void TS_FunctionCall(atributos* res)
{
	if (checkparam != TS[checkProc].parametros)
			printf("[Linea %d] ERROR DE ARGUMENTOS: Número de parametros incorrecto.\n", 
				linea);
		
	else
	{
		res->lexema = strdup(TS[checkProc+checkparam].nombre);
		res->tipo = TS[checkProc+checkparam].tipoDato;
	}
}

void TS_CheckParam(atributos param)
{
	checkparam += 1;
	int formparam = checkProc + checkparam;

	if(checkparam > TS[checkProc].parametros)
			return;

	if(param.tipo != TS[formparam].tipoDato) 
	{
		printf("[Linea %d] ERROR DE ARGUMENTOS: Parámetro %s no válido (Tipo %d, esperado %d).\n", 
			linea, param.lexema, param.tipo, TS[formparam].tipoDato);
		return;
	}
}

int esArray(atributos e)
{
	if(e.tipo == array_int || e.tipo == array_double
		|| e.tipo == array_bool || e.tipo == array_char)
		return 0;
	return 1;
}

int checkIndexArray(int size, atributos ind)
{
	int index = atoi(ind.lexema);
	
	if(index > size)
	{
		printf("[Linea %d] Error semántico: Acceso a Array fuera de rango.\n",
		linea);
		return 1;
	}

	return 0;
}

int checkTipoArray(dtipo a)
{
	if(a == array_int)
		return entero;
	else if(a == array_bool)
		return booleano;
	else if(a == array_char)
		return caracter;
	return real;
}

int checkDimensArray(atributos a, atributos b)
{
	int ARR1 = TS_FindByID(a);
	int ARR2 = TS_FindByID(b);

	int dim_1 = TS[ARR1].dimensiones;
	int dim_2 = TS[ARR2].dimensiones;

	if(dim_1 == dim_2)
	{
		dim_1 = TS[ARR1].TamDimen1;
		dim_2 = TS[ARR2].TamDimen1;

		if(dim_1 != dim_2)
		{
			printf("[Linea %d] Error semántico: Arrays de distinto tamaño.\n",
			linea);
			return -1;
		}

		else
		{
			dim_1 = TS[ARR1].TamDimen2;
			dim_2 = TS[ARR2].TamDimen2;
			
			if(dim_1 != dim_2)
			{
				printf("[Linea %d] Error semántico: Arrays de distinto tamaño.\n",
				linea);
				return -1;
			}
		}
	}

	else
	{
		printf("[Linea %d] Error Semántico: Arrays de distinta dimensión.\n",
		linea);
		return -1;
	}

	return 1;
}

void checkMultArray(atributos a, atributos b, atributos *res)
{
	int ARR1 = TS_FindByID(a);
	int ARR2 = TS_FindByID(b);

	int dim_1 = TS[ARR1].dimensiones;
	int dim_2 = TS[ARR2].dimensiones;

	if(dim_1 == dim_2)
	{
		dim_1 = TS[ARR1].TamDimen2;
		dim_2 = TS[ARR2].TamDimen1;

		if(dim_1 != dim_2)
		{
			printf("[Linea %d] Error semántico: Tamaño de Arrays incorrecto, OP_MULT.\n",
			linea);
			return;
		}

		dim1 = TS[ARR1].TamDimen1;
		dim2 = TS[ARR2].TamDimen2;

		res-> lexema 	= strdup("arrayDePaso");
		res-> atrib 	= 0;
		res-> tipo 		= TS[ARR1].tipoDato;
		
		decVar = 1;
		TS_AddVar(*res);
		decVar = 0;
	}

	else
		printf("[Linea %d] Error Semántico: Arrays de distinta dimensión.\n",
		linea);
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
		case array_int:
			nombre = "array_int";
			break;
		case array_char:
			nombre = "array_char";
			break;
		case array_double:
			nombre = "array_double";
			break;
		case array_bool:
			nombre = "array_bool";
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
	printf("%-5s%-20s%-20s%-15s%-11s%-10s%-5s%-5s\n", 
		"Num", "TipoEnt", "Nombre", "TipoDato", 
		"Parametros", "Dimension", "Tam1", "Tam2");

	for(int i = 0; i < TOPE; i++)
		printf("%-5i%-20s%-20s%-15s%-11i%-10i%-5i%-5i\n",
			i, getEntrada(TS[i].entrada), TS[i].nombre, 
			getTipoDato(TS[i].tipoDato), TS[i].parametros, 
			TS[i].dimensiones, TS[i].TamDimen1, TS[i].TamDimen2);

	printf("\n\n");
	printf("----------------------------------------------------------------------------------------------");
	printf("\n\n");
}

int imprimir_var(entradaTS elem, FILE *fichero)
{
	if(elem.dimensiones)
		fprintf(fichero, "%s", elem.nombre);
	else if(elem.dimensiones == 1)
		fprintf(fichero, "%s[%s]",elem.nombre, elem.TamDimen1);
	else if(elem.dimensiones == 2)
		fprintf(fichero, "%s[%s,%s]", elem.nombre, elem.TamDimen1, elem.TamDimen2);
	else
		return -1;

	return 0;
}

