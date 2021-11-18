/*----- Sección de Declaraciones --------------*/
%{
#define MAXLONGBUFFER 200
char buffer[MAXLONGBUFFER];
%}

%option noyywrap
   /*----- Sección de Alias --------------*/
REAL                 ([0-9]+\.[0-9]+)
NATURAL              ([0-9]+[0-9]*)
ID                   ([a-z]|[A-Z])([a-z]|[A-Z]|[0-9]|\_)*
CARACTER             \'[^\"]\'
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
"**"                 return OPMATRICES;
"*"                  return OP_BINARIO;
"/"                  return OP_BINARIO;
"@"                  return OP_BINARIO;
"--"                 return OP_BINARIO;
"%"                  return OP_BINARIO;
"<"                  return OP_BINARIO;
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
"procedimiento"      return PROCEDIMIENTO;
"int"                return TIPO;
"double"             return TIPO;
"char"               return TIPO;
"bool"               return TIPO;
"var"                return MARCA_INICIO_VAR;
"endvar"             return MARCA_FIN_VAR;
"Entrada"            return ENTRADA;
"Salida"             return SALIDA;
{NATURAL}            return NATURAL;
{REAL}               return CONSTANTE;
{CARACTER}           return CONSTANTE;
"verdadero"          return CONSTANTE;
"falso"              return CONSTANTE;
{CADENA}             return CADENA;
{ID}                 return ID;
[\n]                 linea_actual++;
[ \t]+               ;
.                  {
   error_lexico++;
   snprintf(buffer, MAXLONGBUFFER,"Error léxico %i: token %s en linea %i.\n", error_lexico, yytext, linea_actual);
   yyerror(buffer);
}
%%

