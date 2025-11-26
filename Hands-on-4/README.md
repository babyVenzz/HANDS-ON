# Analizador Léxico en C con Flex

## Integrantes
- Ángel Yahir Vences Arellano

## Descripción
Implementación de analizador léxico para un subconjunto del lenguaje C.  

Reconocimiento de:
- Palabras reservadas (`int`, `float`, `double`, `char`, `void`, `short`, `return`)
- Directivas del preprocesador (`#include`, `#define`)
- Headers tipo `<stdio.h>`
- Identificadores (variables, funciones, macros)
- Literales numéricos
- Operadores (`=`, `==`, `+`, `*`, `/`, `-`, `++`)
- Delimitadores (`(){};,`)
- Comentarios (`//` y `/* ... */`)
- Ignora espacios y saltos de línea

El programa lee un archivo `input.c` y produce como salida una lista de tokens detectados.

## Instrucciones de compilación

1. Generar `lex.yy.c` usando Flex: flex lexer.l
2. Compilar usando GCC: gcc lex.yy.c -o lexer.exe
3. Ejecutar el analizador: lexer.exe < input.c

## Archivo(s)
- `lexer.l` – especificación del analizador léxico
- `input.c` – archivo de prueba con código C
