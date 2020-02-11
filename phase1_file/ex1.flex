%{
    int intCount = 0;
    int pCount, sCount, mCount, dCount, lpCount, rpCount, eCount, yeetC;
%}
LETTER [A-Z, a-z]
DIGIT [0-9]
DEC [.]
L_PAR [(]
R_PAR [)]
PLUS [+]
MINUS [-]
MULT [*]
DIV [/]
EQU [=]
ERROR [^ 0-9,(,),+,-,*,/,=, ,\n,.,"yeet", "if", "else"]
E [e,E]

%%
"\n"
{DIGIT}+?{DEC}?{DIGIT}+?{E}?{DIGIT}+ {printf("NUMBER %s\n", yytext, intCount++); }
{PLUS} {printf("PLUS\n", pCount++); }
{MINUS} {printf("MINUS\n", sCount++); }
{MULT} {printf("MULT\n", mCount++); }
{DIV} {printf("DIV\n", dCount++); }
{L_PAR} {printf("L_PAREN\n", lpCount++); }
{R_PAR} {printf("R_PAREN\n", rpCount++); }
{EQU} {printf("EQUAL\n", eCount++); }
{ERROR} {printf("ERROR\nSHUTTING DOWN\n"); exit(1); }
"yeet" {printf("YEEEEEEEEEEEEEEEEET\n\n\n"); yeetC++;}
"if" {printf("if "); }
"else" {printf("else "); }
LETTER+ {printf("not happenning?\n"); }


%%

int main() {
    yylex();
    printf("yeeted %d times\n", yeetC);
}
