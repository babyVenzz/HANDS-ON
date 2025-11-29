%{
#include <stdio.h>
#include <stdlib.h>

extern int line;
extern int column;
extern char* current_token;

int yylex();
void yyerror(const char *s);
%}

%union {
    int num;
    char* str;
}

%token INT FLOAT DOUBLE CHAR VOID RETURN
%token INCLUDE DEFINE HASH
%token ID NUMBER HEADER
%token EQ ASSIGN PLUS MINUS MUL DIV
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%type <str> ID
%type <num> NUMBER

%left PLUS MINUS
%left MUL DIV

%%

program:
      directive_list global_list
    | global_list
    ;

directive_list:
      directive_list directive
    | directive
    ;

directive:
      HASH INCLUDE HEADER
    | HASH DEFINE ID NUMBER
    ;

global_list:
       global_list global
     | global
     ;

global:
       declaration
     | function
     ;

declaration:
       type ID SEMICOLON
     ;

type:
       INT | FLOAT | DOUBLE | CHAR | VOID
     ;

function:
       type ID LPAREN params RPAREN block
     ;

params:
       param_list
     | /* vacío */
     ;

param_list:
       param_list COMMA param
     | param
     ;

param:
       type ID
     ;

block:
       LBRACE stmt_list RBRACE
     ;

stmt_list:
       stmt_list stmt
     | stmt
     ;

stmt:
       declaration
     | assignment
     | call SEMICOLON
     | RETURN expr SEMICOLON
     | block
     | SEMICOLON
     ;

assignment:
       ID ASSIGN expr SEMICOLON
     ;

call:
       ID LPAREN args RPAREN
     ;

args:
       arg_list
     | /* vacío */
     ;

arg_list:
       arg_list COMMA expr
     | expr
     ;

expr:
       expr PLUS expr
     | expr MINUS expr
     | expr MUL expr
     | expr DIV expr
     | NUMBER
     | ID
     | call
     | LPAREN expr RPAREN
     ;

%%

void yyerror(const char* s) {
    if (current_token == NULL)
        printf("Error: inesperado fin de archivo en linea %d, columna %d\n",
               line, column);
    else
        printf("Error sintactico en linea %d, columna %d: token inesperado '%s'\n",
               line, column, current_token);
}

int main() {
    int result = yyparse();
    if (result == 0)
        printf("Parsing completado sin errores\n");
    return result;
}
