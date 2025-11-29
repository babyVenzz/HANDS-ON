# Hands-on-5 – Crear Analizador Sintáctico

## Integrante
- Angel Yahir Vences Arellano

---

## Descripción General
Se implementa un **analizador léxico (lexer.l)** y un **analizador sintáctico (parser.y)** utilizando **Flex** y **Bison**, diseñados para procesar un subconjunto del lenguaje C.  
El compilador detecta estructuras válidas del lenguaje, reconoce tokens, valida la gramática y reporta errores con información detallada de línea, columna y token inesperado.

---

## 1. Analizador Léxico (`lexer.l`)
El **lexer** transforma la entrada en una secuencia de tokens reconocidos por el parser.

### Tokens que reconoce
- **Palabras clave:**  
  `int`, `float`, `double`, `char`, `void`, `return`

- **Directivas del preprocesador:**  
  `#include`, `#define`

- **Headers en formato:**  
  `<stdio.h>`, `<nombre.h>` o `<archivo.ext>`

- **Identificadores (`ID`):**  
  Nombres de variables y funciones.

- **Números (`NUMBER`)**  
  Reconocimiento de enteros positivos.

- **Operadores:**  
  `+`, `-`, `*`, `/`, `=`, `==`

- **Delimitadores:**  
  `;`, `,`, `(`, `)`, `{`, `}`

- **Comentarios:**  
  - De línea (`// comentario`)
  - Multilínea (`/* ... */`)

- **Control de formato:**  
  Ignora espacios, tabulaciones y saltos de línea.

### Manejo de errores léxicos
Cualquier caracter no reconocido se reporta con:
- Línea exacta  
- Columna exacta  
- Caracter inválido encontrado  

Ejemplo:
Caracter ilegal '$' en linea 4, columna 12

---

## 2. Analizador Sintáctico (`parser.y`)
El **parser** valida la estructura del programa a partir de los tokens generados por el lexer.

### Estructuras reconocidas

#### Directivas
- `#include HEADER`
- `#define ID NUMBER`

#### Declaraciones globales
- `type ID;`

#### Tipos válidos
`int`, `float`, `double`, `char`, `void`

#### Funciones
- Definición:  
  `type ID (params) { stmt_list }`
- Parámetros opcionales: lista separada por comas.
- Soporte para:
  - declaraciones
  - asignaciones
  - llamadas a función
  - sentencias `return`
  - bloques `{ ... }`
  - sentencias vacías `;`

#### Expresiones
- Aritméticas con:
  `+`, `-`, `*`, `/`
- Literales (`NUMBER`)
- Identificadores (`ID`)
- Llamadas a funciones
- Paréntesis para agrupar expresiones

---

## 3. Manejo de Errores Sintácticos 
El parser detecta errores basados en las producciones válidas de la gramática.

### Errores sintácticos simples:
Cuando el token no encaja en la producción esperada:
Error sintactico en linea 7, columna 10: token inesperado '=='

### Errores sintácticos informativos
Reportando:
- Número de **línea**
- Número de **columna**
- **Token exacto** que causó el error
- Detección de **fin de archivo inesperado**

Ejemplo:
Error: inesperado fin de archivo en linea 20, columna 1

## Instrucciones de compilación

1. Generar parser: bison -d parser.y
2. Generar lexer: flex lexer.l
3. Compilar todo: gcc lex.yy.c parser.tab.c -o parser.exe
4. Ejecutar con entrada desde archivo: parser.exe < input.c
   
## Archivo(s)
- `lexer.l` – especificación del analizador léxico
- `parser.y` – especificación del analizador sintáctico
- `input.c` – archivo de prueba con código C
