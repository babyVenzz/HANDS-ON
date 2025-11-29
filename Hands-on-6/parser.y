%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ----------------------------------------------------
   VARIABLES EXTERNAS DEL LEXER
   ---------------------------------------------------- */
extern int line;
extern int column;
extern char* current_token;
int yylex();
void yyerror(const char *s);

/* ----------------------------------------------------
   TABLA DE SÍMBOLOS + SCOPES
   ---------------------------------------------------- */
typedef enum { SYM_VAR, SYM_FUNC, SYM_PARAM } SymKind;

typedef struct Symbol {
    char* name;
    char* type;
    SymKind kind;
    int param_count;
    struct Symbol* next;
} Symbol;

typedef struct Scope {
    Symbol* symbols;
    struct Scope* prev;
} Scope;

static Scope* scope_top = NULL;

/* ---------- helpers ---------- */
void semantic_error(const char* msg) {
    printf("Error semantico en linea %d, columna %d: %s (token: %s)\n",
           line, column, msg, current_token ? current_token : "EOF");
}

/* ---------- manejar pila ---------- */
void push_scope() {
    Scope* s = malloc(sizeof(Scope));
    s->symbols = NULL;
    s->prev = scope_top;
    scope_top = s;
}

void pop_scope() {
    Symbol* sym = scope_top->symbols;
    while (sym) {
        Symbol* tmp = sym;
        sym = sym->next;
        free(tmp->name);
        free(tmp->type);
        free(tmp);
    }
    Scope* old = scope_top;
    scope_top = scope_top->prev;
    free(old);
}

/* ---------- insertar símbolo ---------- */
int insert_symbol(const char* name, const char* type, SymKind kind, int params) {
    Symbol* s = scope_top->symbols;
    while (s) {
        if (strcmp(s->name, name) == 0)
            return 0; // redeclarada en este scope
        s = s->next;
    }
    Symbol* news = malloc(sizeof(Symbol));
    news->name = strdup(name);
    news->type = strdup(type);
    news->kind = kind;
    news->param_count = params;
    news->next = scope_top->symbols;
    scope_top->symbols = news;
    return 1;
}

/* ---------- búsqueda en todos los scopes ---------- */
Symbol* find_symbol_any_scope(const char* name) {
    Scope* sc = scope_top;
    while (sc) {
        Symbol* s = sc->symbols;
        while (s) {
            if (strcmp(s->name, name) == 0)
                return s;
            s = s->next;
        }
        sc = sc->prev;
    }
    return NULL;
}

/* ---------- función global ---------- */
int insert_function_global(const char* name, const char* type, int params) {
    Scope* g = scope_top;
    while (g->prev) g = g->prev;

    Symbol* s = g->symbols;
    while (s) {
        if (strcmp(s->name, name) == 0)
            return 0; // redeclarada globalmente
        s = s->next;
    }
    Symbol* news = malloc(sizeof(Symbol));
    news->name = strdup(name);
    news->type = strdup(type);
    news->kind = SYM_FUNC;
    news->param_count = params;
    news->next = g->symbols;
    g->symbols = news;

    return 1;
}

void init_semantic() {
    push_scope(); // GLOBAL SCOPE
}
%}

/* ----------------------------------------------------
   TIPOS PARA BISON
   ---------------------------------------------------- */
%union {
    int num;
    char* str;
}

%token INT FLOAT DOUBLE CHAR VOID RETURN
%token INCLUDE DEFINE HASH
%token ID NUMBER HEADER
%token EQ ASSIGN PLUS MINUS MUL DIV
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%type <str> ID type
%type <num> NUMBER param_list params arg_list args param

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
      INCLUDE HEADER
    | DEFINE ID NUMBER {
          // Insertar macro como "variable" constante en el scope global
          if (!insert_symbol($2, "int", SYM_VAR, 0)) {
              printf("Error semantico en linea %d, columna %d: Macro '%s' redeclarada\n",
                     line, column, $2);
          }
          free($2);
      }
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
    type ID SEMICOLON {
        char* var_name = strdup($2);
        if (!insert_symbol($2, $1, SYM_VAR, 0))
            printf("Error semantico en linea %d, columna %d: Redeclaracion de variable '%s'\n",
                   line, column, var_name);
        free(var_name);
        free($1);
        free($2);
    }
;

type:
       INT    { $$ = strdup("int"); }
     | FLOAT  { $$ = strdup("float"); }
     | DOUBLE { $$ = strdup("double"); }
     | CHAR   { $$ = strdup("char"); }
     | VOID   { $$ = strdup("void"); }
     ;

function:
       type ID LPAREN params RPAREN block {
            char* func_name = strdup($2);  // guardar nombre real
            if (!insert_function_global($2, $1, $4))
                printf("Error semantico en linea %d, columna %d: Redeclaracion de funcion '%s'\n",
                       line, column, func_name);
            free(func_name);
            free($1);
            free($2);
       }
     ;

params:
       param_list { $$ = $1; }
     | /* vacío */ { $$ = 0; }
     ;

param_list:
       param_list COMMA param { $$ = $1 + $3; }
     | param { $$ = $1; }
     ;

param:
       type ID {
            if (!insert_symbol($2, $1, SYM_PARAM, 0))
                semantic_error("Parametro redeclarado");
            free($1);
            free($2);
            $$ = 1;
       }
     ;

block:
       LBRACE { push_scope(); }
       stmt_list
       RBRACE { pop_scope(); }
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
     | error SEMICOLON { yyerror("Error sintáctico"); yyerrok; }
     ;

assignment:
    ID ASSIGN expr SEMICOLON {
        Symbol* s = find_symbol_any_scope($1);
        char* token_name = strdup($1); // guardar el token real
        if (!s) {
            printf("Error semantico en linea %d, columna %d: Variable '%s' no declarada\n",
                   line, column, token_name);
        }
        free(token_name);
        free($1);
    }
;


call:
    ID LPAREN args RPAREN {
        Symbol* f = find_symbol_any_scope($1);
        char* func_name = strdup($1);
        if (!f || f->kind != SYM_FUNC)
            printf("Error semantico en linea %d, columna %d: Llamada a funcion '%s' no declarada\n",
                   line, column, func_name);

        if (f && f->param_count != $3)
            printf("Error semantico en linea %d, columna %d: Numero de argumentos incorrecto para '%s'\n",
                   line, column, func_name);

        free(func_name);
        free($1);
    }
;

args:
       arg_list { $$ = $1; }
     | /* vacío */ { $$ = 0; }
     ;

arg_list:
       arg_list COMMA expr { $$ = $1 + 1; }
     | expr { $$ = 1; }
     ;

expr:
       expr PLUS expr
     | expr MINUS expr
     | expr MUL expr
     | expr DIV expr
     | NUMBER
     | ID {
            Symbol* s = find_symbol_any_scope($1);
            char* var_name = strdup($1);  // guardar el nombre real
            if (!s) {
                printf("Error semantico en linea %d, columna %d: Variable '%s' usada sin declarar\n",
                       line, column, var_name);
            }
            free(var_name);
            free($1);
       }
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
    init_semantic();
    int result = yyparse();
    if (result == 0)
        printf("Parsing completado sin errores\n");
    return result;
}
