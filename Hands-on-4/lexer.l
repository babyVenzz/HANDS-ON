%{
#include <stdio.h>
int line = 1;
%}

%option noyywrap

%%

"int"               { printf("TOKEN_KEYWORD_INT\n"); }
"float"             { printf("TOKEN_KEYWORD_FLOAT\n"); }
"double"            { printf("TOKEN_KEYWORD_DOUBLE\n"); }
"char"              { printf("TOKEN_KEYWORD_CHAR\n"); }
"void"              { printf("TOKEN_KEYWORD_VOID\n"); }
"short"             { printf("TOKEN_KEYWORD_SHORT\n"); }
"return"            { printf("TOKEN_RETURN\n"); }
"include"           { printf("TOKEN_INCLUDE\n"); }
"define"            { printf("TOKEN_DEFINE\n"); }

"#"                 { printf("TOKEN_HASH\n"); }

"<"[a-zA-Z0-9_.]+">"   { printf("TOKEN_HEADER(%s)\n", yytext); }

[0-9]+              { printf("TOKEN_NUMBER(%s)\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("TOKEN_ID(%s)\n", yytext); }

"=="                { printf("TOKEN_EQ\n"); }
"="                 { printf("TOKEN_ASSIGN\n"); }
"++"                { printf("TOKEN_INC\n"); }
"+"                 { printf("TOKEN_PLUS\n"); }
"-"                 { printf("TOKEN_MINUS\n"); }
"*"                 { printf("TOKEN_MUL\n"); }
"/"                 { printf("TOKEN_DIV\n"); }

";"                 { printf("TOKEN_SEMICOLON\n"); }
","                 { printf("TOKEN_COMMA\n"); }
"("                 { printf("TOKEN_LPAREN\n"); }
")"                 { printf("TOKEN_RPAREN\n"); }
"{"                 { printf("TOKEN_LBRACE\n"); }
"}"                 { printf("TOKEN_RBRACE\n"); }

"//".*              { /* comentario de línea */ }

\/\*([^*]|\*+[^*/])*\*\/   { /* comentario bloque */ }

[ \t]+              { /* ignora espacios */ }
\n                  { line++; }

.                   { printf("TOKEN_UNKNOWN(%s)\n", yytext); }

%%

int main() {
    yylex();
    return 0;
}

