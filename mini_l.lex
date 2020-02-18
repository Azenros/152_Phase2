%{
  #include "mini_l.y"
  void separate();
  int line = 1;
  int space = 0;
  int tabspaces = 8;
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

%%
"\n" {line++; space = 0;}
"\t".* {yyless(1);space += tabspaces;}
"##".* {line++; space = 0;}
"function".* {yyless(9); space += 9; printf("FUNCTION\n"); }
"beginparams".* {yyless(11); space += 11; printf("BEGIN_PARAMS\n"); }
"endparams".* {yyless(9); space += 9; printf("END_PARAMS\n"); }
"beginlocals".* {yyless(11); space += 11; printf("BEGIN_LOCALS\n"); }
"endlocals".* {yyless(9); space += 9; printf("END_LOCALS\n"); }
"beginbody".* {yyless(9); space += 9; printf("BEGIN_BODY\n"); }
"endbody".* {yyless(7); space += 7; printf("END_BODY\n"); }
"integer".* {yyless(7); space += 7; printf("INTEGER\n"); }
"array".* {yyless(5); space += 5; printf("ARRAY\n"); }
"of".* {yyless(3); space += 3; printf("OF\n"); }
"if".* {yyless(2); space += 2; printf("IF\n"); }
"then".* {yyless(4); space += 4; printf("THEN\n"); }
"endif".* {yyless(5); space += 5; printf("ENDIF\n"); }
"else".* {yyless(4); space += 4; printf("ELSE\n"); }
"while".* {yyless(5); space += 5; printf("WHILE\n"); }
"do".* {yyless(2); space += 2; printf("DO\n"); }
"for".* {yyless(3); space += 3; printf("FOR\n"); }
"beginloop".* {yyless(9); space += 9; printf("BEGINLOOP\n"); }
"endloop".* {yyless(7); space += 7; printf("ENDLOOP\n"); }
"continue".* {yyless(8); space += 8; printf("CONTINUE\n"); }
"read".* {yyless(4); space += 4; printf("READ\n"); }
"write".* {yyless(5); space += 5; printf("WRITE\n"); }
"and".* {yyless(3); space += 3; printf("AND\n"); }
"or".* {yyless(2); space += 2; printf("OR\n"); }
"not".* {yyless(3); space += 3; printf("NOT\n"); }
"true".* {yyless(4); space += 4; printf("TRUE\n"); }
"false".* {yyless(5); space += 5; printf("FALSE\n"); }
"return".* {yyless(6); space += 6; printf("RETURN\n"); }
"==" {printf("EQ\n"); space += 2; }
"<>" {printf("NEQ\n"); space += 2; }
"<" {printf("LT\n"); space++; }
">" {printf("GT\n"); space++; }
"<=" {printf("LTE\n"); space += 2; }
">=" {printf("GTE\n"); space += 2; }
";" {printf("SEMICOLON\n"); space++; }
"(" {printf("L_PAREN\n"); space++; }
")" {printf("R_PAREN\n"); space++; }
"[" {printf("L_SQUARE_BRACKET\n"); space++; }
"]" {printf("R_SQUARE_BRACKET\n"); space++; }
":=" {printf("ASSIGN\n"); space += 2; }
":" {printf("COLON\n"); space++; }
"," {printf("COMMA\n"); space++; }

{SUB} {printf("SUB\n"); space++; }
{ADD} {printf("ADD\n"); space++; }
{MULT} {printf("MULT\n"); space++; }
{DIV} {printf("DIV\n"); space++; }
{MOD} {printf("MOD\n"); space++; } 
{SPACE}+ {yyless(1); space++; }
{DIGIT}+ {printf("NUMBER %s\n", yytext); }
{DIGIT}+{USCORE}?{LETTER}+ {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, space, yytext); exit(1); }
{USCORE}({LETTER}*{DIGIT}*)* {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, space, yytext); exit(1); }
({LETTER}?{DIGIT}?)*{USCORE}+ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line, space, yytext); exit(1); }
{ERROR} {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, space, yytext); exit(1); }
({LETTER}?{DIGIT}?)+{USCORE}?({LETTER}?{DIGIT}?)* {yyless(yyleng); printf("IDENT %s\n", yytext); space += yyleng; }


%%

int main() {
    yylex();
}
