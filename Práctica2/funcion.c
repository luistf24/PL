#include <stdio.h>

void imprimirToken(int val)
{
   char lexema[20];
   switch(val)
   {
      case 257:
         printf("Principal");
         break;
      case 258:
         printf("INICIO_BLOQUE");
         break;
      case 259:
         printf("FIN_BLOQUE");
         break;
      case 260:
         printf("PYC");
         break;
      case 261:
         printf("COMA");
         break;
      case 262:
         printf("PARENT_IZQ");
         break;
      case 263:
         printf("PARENT_DER");
         break;
      case 264:
         printf("CORCHETE_DER");
         break;
      case 265:
         printf("CORCHERTE_IZQ");
         break;
      case 266:
         printf("SI");
         break;
      case 267:
         printf("SINO");
         break;
      case 268:
         printf("MIENTRAS");
         break;
      case 269:
         printf("HACER");
         break;
      case 270:
         printf("HASTA");
         break;
      case 271:
         printf("OP_ASIG");
         break;
      case 272:
         printf("OP_UNARIO");
         break;
      case 273:
         printf("OP_BINARIO");
         break;
      case 274:
         printf("CONSTANTE");
         break;
      case 275:
         printf("ID");
         break;
      case 276:
         printf("PROCEDIMIENTO");
         break;
      case 277:
         printf("TIPO");
         break;
      case 278:
         printf("MARCA_INICIO_VAR");
         break;
      case 279:
         printf("ENTRADA");
         break;
      case 280:
         printf("SALIDA");
         break;
      default:
         printf("CADENA");
   }
}