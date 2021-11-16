/*----- Sección de Declaraciones --------------*/
%{
%}

%option noyywrap
   /*----- Sección de Alias --------------*/
CONSTANTE            ([0-9]+\.[0-9]+)
NATURAL              ([0-9]+[0-9]*)
ID                   ([a-z]|[A-Z])([a-z]|[A-Z]|\_)*
CADENA	 		      \"[^\"]+\"
otros			.

%%
   /*----- Sección de Reglas ----------------*/

"Principal"          return PRINCIPAL;
"{"                  return INICIO_BLOQUE;
"}"                  return FIN_BLOQUE;
";"                  return PYC;
","                  return COMA;
"("                  return PARENT_IZQ;
")"                  return PARENT_DER;
"["                  return CORCHETE_IZQ;
"]"                  return CORCHETE_DER;
"si"                 return SI;
"sino"               return SINO;
"mientras"           return MIENTRAS;
"hacer"              return HACER;
"hasta"              return HASTA;
"="                  return OP_ASIG;
"*"                  return OP_BINARIO;
"/"                  return OP_BINARIO;
"@"                  return OP_BINARIO;
"--"                 return OP_BINARIO;
"%"                  return OP_BINARIO;
"**"                 return OP_BINARIO;
"<"                  return OPMATRICES;
">"                  return OP_BINARIO;
"=="                 return OP_BINARIO;
">="                 return OP_BINARIO;
"<="                 return OP_BINARIO;
"&&"                 return OP_BINARIO;
"||"                 return OP_BINARIO;
"^"                  return OP_BINARIO;
"+"                  return MASMENOS;
"-"                  return MASMENOS;
"!"                  return OP_UNARIO;
"verdadero"          return CONSTANTE;
"falso"              return CONSTANTE;
"procedimiento"      return PROCEDIMIENTO;
"int"                return TIPO;
"double"             return TIPO;
"char"               return TIPO;
"booleano"           return TIPO;
"var"                return MARCA_INICIO_VAR;
"endvar"             return MARCA_FIN_VAR;
"Entrada"            return ENTRADA;
"Salida"             return SALIDA;
{NATURAL}            return NATURAL;
{CONSTANTE}          return CONSTANTE;
{CADENA}             return CADENA;
{ID}                 return ID;
[\n]                 linea_actual++;
[ \t]+               ;
{otros}              {  error_lexico++;
                        printf("Error léxico %i: token %s en linea %i.\n", error_lexico, yytext, linea_actual);
                     }
%%

