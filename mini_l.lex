%{
  #include <iostream>
  #include <stdio.h>
  #include <string>
  #include <stdlib.h>
  #include "tok.h"
  int line = 1;
  int space = 0;
  int tabspaces = 8;

  int yyparse();
%}

DIGIT [0-9]
LETTER [a-zA-Z]
USCORE [_]
SUB [-]
ADD [+]
MULT [*]
DIV [/]
MOD [%]
SPACE [ ]
ERROR [^0-9A-Za-z)(+*/%\n\t-]

%option nounput

%%
"\n" {line++; space = 0;}
"\t".* {yyless(1);space += tabspaces;}
"##".* {line++; space = 0;}

"function".* {yyless(9); space += 9; return FUNCTION;}
"beginparams".* {yyless(11); space += 11; return BEGIN_PARAMS;}
"endparams".* {yyless(9); space += 9; return END_PARAMS;}
"beginlocals".* {yyless(11); space += 11; return BEGIN_LOCALS;}
"endlocals".* {yyless(9); space += 9; return END_LOCALS;}
"beginbody".* {yyless(9); space += 9; return BEGIN_BODY;}
"endbody".* {yyless(7); space += 7; return END_BODY;}
"integer".* {yyless(7); space += 7; return INTEGER;}
"array".* {yyless(5); space += 5; return ARRAY;}
"of".* {yyless(3); space += 3; return OF;}
"if".* {yyless(2); space += 2; return IF;}
"then".* {yyless(4); space += 4; return THEN;}
"endif".* {yyless(5); space += 5; return ENDIF;}
"else".* {yyless(4); space += 4; return ELSE;}
"while".* {yyless(5); space += 5; return WHILE;}
"do".* {yyless(2); space += 2; return DO;}
"for".* {yyless(3); space += 3; return FOR;}
"beginloop".* {yyless(9); space += 9; return BEGINLOOP;}
"endloop".* {yyless(7); space += 7; return ENDLOOP;}
"continue".* {yyless(8); space += 8; return CONTINUE;}
"read".* {yyless(4); space += 4; return READ;}
"write".* {yyless(5); space += 5; return WRITE;}
"and".* {yyless(3); space += 3; return AND;}
"or".* {yyless(2); space += 2; return OR;}
"not".* {yyless(3); space += 3; return NOT;}
"true".* {yyless(4); space += 4; return TRUE;}
"false".* {yyless(5); space += 5; return FALSE;}
"return".* {yyless(6); space += 6; return RETURN;}
"==" {space += 2; return EQ;}
"<>" {space += 2; return NEQ;}
"<" {space++; return LT;}
">" {space++; return GT;}
"<=" {space += 2; return LTE;}
">=" {space += 2; return GTE;}
";" {space++; return SEMICOLON;}
"(" {space++; return L_PAREN;}
")" {space++; return R_PAREN;}
"[" {space++; return L_SQUARE_BRACKET;}
"]" {space++; return R_SQUARE_BRACKET;}
":=" {space += 2; return ASSIGN;}
":" {space++; return COLON;}
"," {space++; return COMMA;}

{SUB} {space++; return SUB;}
{ADD} {space++; return ADD;}
{MULT} {space++; return MULT;}
{DIV} {space++; return DIV;}
{MOD} {space++; return MOD;} 
{SPACE}+ {yyless(1); space++;}
{DIGIT}+ {space += yyleng; yylval.ival = atoi(yytext); return NUMBER;}
{DIGIT}+{USCORE}?{LETTER}+ {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, space, yytext); exit(1);}
{USCORE}({LETTER}*{DIGIT}*)* {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, space, yytext); exit(1);}
({LETTER}?{DIGIT}?)*{USCORE}+ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line, space, yytext); exit(1);}
{ERROR} {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, space, yytext); exit(1); }
({LETTER}?{DIGIT}?)+{USCORE}?({LETTER}?{DIGIT}?)* {yyless(yyleng); space += yyleng; return IDENT;}


%%

int main() {
    yylex();
    yyparse();
}
