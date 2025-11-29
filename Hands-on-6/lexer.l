%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line = 1;
int column = 1;
char* current_token = NULL;
%}

%option noyywrap

%%

"int"               { current_token = "int"; column += yyleng; return INT; }
"float"             { current_token = "float"; column += yyleng; return FLOAT; }
"double"            { current_token = "double"; column += yyleng; return DOUBLE; }
"char"              { current_token = "char"; column += yyleng; return CHAR; }
"void"              { current_token = "void"; column += yyleng; return VOID; }
"return"            { current_token = "return"; column += yyleng; return RETURN; }

"#include"          { current_token = "include"; column += yyleng; return INCLUDE; }
"#define"           { current_token = "define"; column += yyleng; return DEFINE; }

"<"[a-zA-Z0-9_.]+">" {
    char* tmp = strdup(yytext);
    tmp[strlen(tmp)-1] = '\0';
    yylval.str = strdup(tmp+1);
    free(tmp);
    current_token = "HEADER";
    column += yyleng;
    return HEADER;
}

[0-9]+ {
    yylval.num = atoi(yytext);
    current_token = "NUMBER";
    column += yyleng;
    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    current_token = yytext;
    column += yyleng;
    return ID;
}

"=="        { current_token = "=="; column += yyleng; return EQ; }
"="         { current_token = "="; column += yyleng; return ASSIGN; }
"+"         { current_token = "+"; column += yyleng; return PLUS; }
"-"         { current_token = "-"; column += yyleng; return MINUS; }
"*"         { current_token = "*"; column += yyleng; return MUL; }
"/"         { current_token = "/"; column += yyleng; return DIV; }

";"         { current_token = ";"; column += yyleng; return SEMICOLON; }
","         { current_token = ","; column += yyleng; return COMMA; }
"("         { current_token = "("; column += yyleng; return LPAREN; }
")"         { current_token = ")"; column += yyleng; return RPAREN; }
"{"         { current_token = "{"; column += yyleng; return LBRACE; }
"}"         { current_token = "}"; column += yyleng; return RBRACE; }


"//".*      { column += yyleng; }

"/*" {
    column += 2;
    int c;
    while ((c = input()) != 0) {
        if (c == '\n') { line++; column = 1; }
        else { column++; }
        if (c == '*') {
            int c2 = input();
            if (c2 == '/') { column++; break; }
            unput(c2);
        }
    }
}

[ \t]+      { column += yyleng; }

\n          { line++; column = 1; }

. {
    printf("Caracter ilegal '%s' en linea %d, columna %d\n",
           yytext, line, column);
    column += yyleng;
}

%%