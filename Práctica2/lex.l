/*----- Sección de Declaraciones --------------*/
%{

#include <stdio.h>
#include "tabla.h"
#include "funcion.c"

int linea_actual = 1;
int ERROR = -2;

%}
   /*----- Sección de Alias --------------*/

CONSTANTE            ([0-9]+[0-9]*)|([0-9]+\.[0-9]+)
ID                   ([a-z]|[A-Z])([a-z]|[A-Z]|[0-9]|\_)*
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
"["                  return CORCHERTE_IZQ;
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
"<"                  return OP_BINARIO;
">"                  return OP_BINARIO;
"=="                 return OP_BINARIO;
">="                 return OP_BINARIO;
"<="                 return OP_BINARIO;
"&&"                 return OP_BINARIO;
"||"                 return OP_BINARIO;
"^"                  return OP_BINARIO;
"+"                  return OP_BINARIO;
"-"                  return OP_BINARIO;
"!"                  return OP_UNARIO;
"procedimiento"      return PROCEDIMIENTO;
"int"                return TIPO;
"double"             return TIPO;
"char"               return TIPO;
"bool"               return TIPO;
"var"                return MARCA_INICIO_VAR;
"Entrada"            return ENTRADA;
"Salida"             return SALIDA;
{CONSTANTE}          return CONSTANTE;
{CADENA}             return CADENA;
{ID}                 return ID;
[\n]                 linea_actual++;
[ \t]+               ;
{otros}             return ERROR;
%%
main (int argc, char *argv[])
{
   if (argc >= 2)
   {
      yyin = fopen (argv[1], "rt");
      int val;

      if (yyin == NULL)
      {
         printf ("El fichero %s no se puede abrir\n", argv[1]);
         exit (-1);
      }
      
      else
         printf("<Linea N> <Token> → <Lexema>\n");
      
      val = 1;
      while (val != 0)
      {
         val = yylex();
         if(val > 0)
         {
            printf(" Linea %d: ", linea_actual); 
            imprimirToken(val);
            printf(" → %s\n", yytext);
         }
         
         else if (val == ERROR)
            printf(" Linea %d: [Error léxico] → %s\n", 
            linea_actual, yytext); 
      }
   }
   
   return 0;
}
