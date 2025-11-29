# Análisis Semántico con Tablas de Símbolos y Scopes

**Integrante:** Angel Yahir Vences Arellano

---

## Descripción general

Se extiende el parser del Hands-on 5 para implementar un análisis semántico en lenguaje C.  
El análisis semántico incluye:

- **Validación de variables no declaradas** (locales y globales), mostrando línea, columna y token involucrado.  
- **Detección de redeclaraciones** de variables, constantes y funciones, tanto en scopes globales como locales.  
- **Verificación del número de parámetros** en llamadas a funciones.  
- **Gestión de scopes** mediante una pila de scopes para bloques anidados y funciones, permitiendo detectar redeclaraciones locales.  
- **Manejo de macros (`#define`)** como constantes semánticas registradas en la tabla de símbolos global.  
- **Detección de funciones no declaradas**, con mensajes claros de error indicando la línea, columna y token.  

El parser reporta **errores semánticos claros** indicando la línea, columna y el token implicado.  
También reporta errores sintácticos y lexicos de la anterior implementacion.

---

## Archivos incluidos

- `parser.y` → Archivo que implementa el parser y análisis semántico.  
- `lexer.l` → Archivo que implementa el lexer, maneja tokens, línea y columna.  
- `input.c` → Programa de prueba original.
- `input2.c` → Programa de prueba completa.

---

## Instrucciones de compilación

1. Generar el parser y lexer usando Flex y Bison:

bison -d parser.y        # genera parser.tab.c y parser.tab.h
flex lexer.l             # genera lex.yy.c
gcc lex.yy.c parser.tab.c -o semantico


