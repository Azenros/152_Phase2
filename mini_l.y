%{
  #include <iostream>
  #include <stdio.h>
  #include <string>
  #include <stdlib.h>
  using namespace std;
  int yylex();
  int yyerror(string s);
  int yyerror(char* c);
  //scroll down for full grammar
%}

%union {
	int ival;
	char* sval;
}

%start start

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY FOR OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN
%token <ival> NUMBER
%token <sval> IDENT
%left MULT DIV MOD ADD SUB
%left EQ NEQ LT GT LTE GTE
%right NOT
%left AND OR 
%right ASSIGN


%%

start:
	program { cout << "start -> program\n"; }
;

program:
	function program { cout << "program -> function\n"; }
	| %empty { cout << "program -> epsilon\n"; }
;

function:
	FUNCTION IDENT SEMICOLON parameters declarations parameters declarations parameters statements parameters {
		cout << "function -> FUNCTION IDENT SEMICOLON parameters declarations parameters declarations parameters statements parameters\n"; 
		}
;

parameters:
	BEGIN_PARAMS { 
		cout << "parameters -> BEGIN_PARAMS\n"; 
		}
	| END_PARAMS BEGIN_LOCALS { 
		cout << "parameters -> END_PARAMS BEGIN_LOCALS\n"; 
		}
	| END_LOCALS BEGIN_BODY { 
		cout << "parameters -> END_LOCALS BEGIN_BODY\n"; 
		}
	| END_BODY { 
		cout << "parameters -> END_BODY\n"; 
		}
;

declarations:
	declaration SEMICOLON declarations {
		cout << "declarations -> declaration SEMICOLON declarations\n"; 
		}
	| %empty { cout << "declarations -> epsilon\n"; }
;

declaration:
	identify COLON declaration_2 {
		cout << "declaration -> identify COLON declaration_2\n"; 
		}
;

identify:
	IDENT {
		cout << "identify -> IDENT " << $1 << endl;
		}
	| IDENT COMMA identify {
		cout << "identify -> IDENT " << $1 << " COMMA identify\n";
		}
;

declaration_2:
	INTEGER {
		cout << "declaration_2 -> INTEGER\n"; 
		}
	| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
		cout << "declaration_2 -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"; 
		}
;

statements:
	statement SEMICOLON statements {
		cout << "statements -> statement SEMICOLON statements\n";
		}
	| statement SEMICOLON { cout << "statements -> statement SEMICOLON\n"; }
;

statement:
	var ASSIGN AS_expr {
		cout << "statement -> var ASSIGN AS_expr\n";
		}
	| IF OR_expr THEN statements ENDIF {
		cout << "statement -> IF OR_expr THEN statements ENDIF\n";
		}
	| IF OR_expr THEN statements ELSE statements ENDIF {
		cout << "statement -> IF OR_expr THEN statements ELSE statements ENDIF\n";
		}
	| WHILE OR_expr BEGINLOOP statements ENDLOOP {
		cout << "statement -> WHILE OR_expr BEGINLOOP statements ENDLOOP\n";
		}
	| DO BEGINLOOP statements ENDLOOP WHILE OR_expr {
		cout << "statement -> DO BEGINLOOP statements ENDLOOP WHILE OR_expr\n";
		}
	| FOR var ASSIGN NUMBER SEMICOLON OR_expr SEMICOLON var ASSIGN AS_expr BEGINLOOP statements ENDLOOP {
		cout << "statement -> FOR var ASSIGN NUMBER SEMICOLON OR_expr SEMICOLON var Assign AS_expr BEGINLOOP statements ENDLOOP\n";
		}
	| READ var vars {
		cout << "statement -> READ var vars\n";
		}
	| WRITE var vars {
		cout << "statement -> WRITE var vars\n";
		}
	| CONTINUE {
		cout << "statement -> CONTINUE\n";
		}
	| RETURN AS_expr {
		cout << "statement -> RETURN AS_expr\n";
		}
		
;

OR_expr:
	OR_expr OR AND_expr {
		cout << "OR_expr -> OR_expr OR AND_expr\n";
		}
	| AND_expr {
		cout << "OR_expr -> AND_expr\n";
		}
;

AND_expr:
	AND_expr AND NOT_expr {
		cout << "AND_expr -> AND_expr AND NOT_expr\n";
		}
	| NOT_expr {
		cout << "AND_expr -> NOT_expr\n";
		}
;

NOT_expr:
	NOT REL_expr {
		cout << "NOT_expr -> NOT REL_expr\n";
		}
	| REL_expr {
		cout << "NOT_expr -> REL_expr\n";
		}
;

REL_expr:
	AS_expr comp AS_expr {
		cout << "REL_expr -> AS_expr comp AS_expr\n";
		}
	| L_PAREN OR_expr R_PAREN {
		cout << "REL_expr -> L_PAREN OR_expr R_PAREN\n";
		}
	| TRUE {
		cout << "REL_expr -> TRUE\n";
		}
	| FALSE {
		cout << "REL_expr -> FALSE\n";
		}
;

comp:
	GT {
		cout << "comp -> GT\n";
		}
	| LT {
		cout << "comp -> LT\n";
		}
	| GTE {
		cout << "comp -> GTE\n";
		}
	| LTE {
		cout << "comp -> LTE\n";
		}
	| EQ {
		cout << "comp -> EQ\n";
		}
	| NEQ {
		cout << "comp -> NEQ\n";
		}
;

AS_expr:
	MDM_expr AS_expr2 { 
		cout << "AS_expr -> MDM_expr AS_expr2\n"; 
		}
;

AS_expr2:
	%empty { 
		cout << "AS_expr2 -> epsilon\n"; 
		}
	| ADD AS_expr { 
		cout << "AS_expr2 -> ADD AS_expr\n";
		}
	| SUB AS_expr { 
		cout << "AS_expr2 -> SUB AS_expr\n";
		}
;

MDM_expr:
	NEG_term MDM_expr2{ 
		cout << "MDM_expr -> NEG_term MDM_expr2\n"; 
		}
;

MDM_expr2:
	%empty { 
		cout << "MDM_expr2 -> epsilon\n"; 
		}
	| MOD MDM_expr { 
		cout << "MDM_expr2 -> MOD MDM_expr\n";
		}
	| MULT MDM_expr { 
		cout << "MDM_expr2 -> MULT MDM_expr\n";
		}
	| DIV MDM_expr	{ 
		cout << "MDM_expr2 -> DIV MDM_expr\n";
		}
; 

NEG_term:
	SUB term { 
		cout << "NEG_term -> SUB NEG_term\n";
		}
	| term {
		cout << "NEG_term -> NEG_term\n";
		}
	| IDENT term_id {
		cout << "NEG_term -> IDENT term_id \n";
		}
;

term:
	var { 
		cout << "term -> var\n"; 
		}
	| L_PAREN AS_expr R_PAREN {
		cout << "term -> L_PAREN AS_expr R_PAREN\n";
		}
	| NUMBER {
		cout << "term -> NUMBER " << ($1) << endl;
		}
;

term_id:
	L_PAREN term_ex R_PAREN {
		cout << "term_id -> L_PAREN term_ex R_PAREN\n";
		}
	| L_PAREN R_PAREN {
		cout << "term_id-> L_PAREN  R_PAREN\n";
		}
;

term_ex:
	AS_expr COMMA term_ex {
		cout << "term_ex -> AS_expr COMMA term_ex\n";
		}
	| AS_expr {
		cout << "term_ex -> AS_expr\n";
		}
;

term_exp:
	COMMA term_ex {
		cout << "term_exp -> COMMA term_ex\n";
		}
	| %empty {
		cout << "term_exp -> epsilon\n";
		}
;

vars:
	COMMA vars {
		cout << "vars -> var COMMA vars\n";
		}
	| %empty {
		cout << "vars -> epsilon\n";
		}
;

var:
	IDENT {
		cout << "var -> IDENT " << ($1) << endl;
		}
	| IDENT L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET {
		cout << "var -> IDENT " << ($1) << " L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n";
		}
;




%%

int yyerror(string s) {
    extern int line, space;
    extern char* yytext;
    cout << "Error at line " << line << ", column " << space << ": " << s << ": " << yytext << endl;
    exit(1);
    return 0;
} 
int yyerror(char* c) {
    return yyerror(string(c));
}
