/*----- Sección de Declaraciones --------------*/
%{

#include <stdio.h>
#include "tabla.h"
/*using namespace std;*/

int linea_actual = 1;

%}
   /*----- Sección de Alias --------------*/

CADENA	 		      \"[^\"]+\"
ID                   ([a-z]|[A-Z])([a-z]|[A-Z]|[0-9]|\_)*
CONSTANTE   			([0-9]+\.([0-9])*) | ([0-9]*\.([0-9])+)
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
"!"                  return OP_UNARIO;
"procedimiento"      return PROCEDIMIENTO;
"int"                return TIPO;
"double"             return TIPO;
"char"              return TIPO;
"bool"               return TIPO;
"var"                return MARCA_INICIO_VAR;
"Entrada"            return ENTRADA;
"Salida"             return SALIDA;
CONSTANTE          return CONSTANTE;
CADENA             return CADENA;
ID                 return ID;
[\n]                 linea_actual++;
[/t]+               return -1;
otros              {
                     printf("Error léxico: token %c en linea %c \n", yytext, linea_actual);
                   }
%%
main (int argc, char *argv[])
{
/*otros              cout << "Error léxico: token " << yytext << " en linea "<< linea_actual << endl;*/
/*el programa es en c*/
   if (argc >= 2)
   {
      yyin = fopen (argv[1], "rt");
      int val;

      if (yyin == NULL)
      {
         printf ("El fichero %s no se puede abrir\n", argv[1]);
         exit (-1);
      }
      
      val = 1;
      while (val != 0)
      {
         val = yylex();
         if(val != -1)
           /* cout << "Linea " << linea_actual << ": " << val << endl;*/
            printf(" Linea %d : %d \n", linea_actual, val);
      }
   }
   
   return 0;
}
