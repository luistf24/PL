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
"entonces"           return ENTONCES;
"sino"               return SINO;
"mientras"           return MIENTRAS;
"hacer"              return HACER;
"hasta"              return HASTA;
"="                  return OP_ASIG;
"**"                 return OP_MULT;
"*"                  return OP_MULT;
"/"                  return OP_MULT;
"<"                  return OP_REL;
">"                  return OP_REL;
">="                 return OP_REL;
"<="                 return OP_REL;
"=="                 return OP_IGUALDAD;
"!="                 return OP_IGUALDAD;
"&&"                 return OP_AND;
"||"                 return OP_OR;
"!"                  return OP_NOT;
"xor"                return OP_XOR;
"+"                  return MASMENOS;
"-"                  return MASMENOS;
"procedimiento"      return PROCEDIMIENTO;
"int"                {yylval.tipo= entero; return TIPO;}
"double"             {yylval.tipo= real; return TIPO;}
"char"               {yylval.tipo= caracter; return TIPO;}
"bool"               {yylval.tipo= booleano; return TIPO;}
"var"                return MARCA_INICIO_VAR;
"endvar"             return MARCA_FIN_VAR;
"Entrada"            return ENTRADA;
"Salida"             return SALIDA;
{NATURAL}            {yylval.lexema= strdup(yytext); return NATURAL;}
{REAL}               {yylval.lexema= strdup(yytext); return CONSTANTE;}
{CARACTER}           return CONSTANTE;
"verdadero"          return CONSTANTE;
"falso"              return CONSTANTE;
{CADENA}             return CADENA;
{ID}                 {yylval.lexema= strdup(yytext); return ID;}
[\n]                 linea_actual++;
[ \t]               ;
.                  {
   error_lexico++;
   snprintf(buffer, MAXLONGBUFFER,"Error léxico %i: token %s en linea %i.\n", error_lexico, yytext, linea_actual);
   yyerror(buffer);
}
%%

