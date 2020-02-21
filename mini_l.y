%{
  #include <iostream>
  #include <stdio.h>
  #include <string>
  #include <stdlib.h>
  using namespace std;

  int line = 1;
  int space = 0;
  //scroll down for full grammar
%}

%union {
	int ival;
	string sval;
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
		cout << "function -> FUNCTION" << $2 << "SEMICOLON parameters declarations parameters declarations parameters statements parameters\n"; 
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
		cout << "identify -> " << $1 << endl;
		}
	IDENT COMMA identify {
		cout << "identify -> "  << $1 << " COMMA identify\n";
		}
;

declaration_2:
	INTEGER {
		cout << "declaration_2 -> INTEGER\n"; 
		}
	| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
		cout << "declaration_2 -> ARRAY L_SQUARE_BRACKET " << $3 << " R_SQUARE_BRACKET OF INTEGER\n"; 
		}
;

statements:
	statement SEMICOLON statements {
		cout << "statements -> statement SEMICOLON statements\n";
		}
	| %empty { cout << "statements -> epsilon\n"; }
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
	| READ vars {
		cout << "statement -> READ vars\n";
		}
	| WRITE vars {
		cout << "statement -> WRITE vars\n";
		}
	| CONTINUE {
		cout << "statement -> CONTINUE\n";
		}
	| RETURN AS_expr {
		cout << "statement -> RETURN AS_expr\n";
		}
		
;

OR_expr:
	AND_expr OR OR_expr {
		cout << "OR_expr -> AND_expr OR OR_expr\n";
		}
	| AND_expr {
		cout << "OR_expr -> AND_expr\n";
		}
;

AND_expr:
	REL_expr AND AND_expr {
		cout << "AND_expr -> NOT_expr AND AND_expr\n";
		}
	| REL_expr {
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
		cout << "NEG_term -> SUB term\n";
		}
	| term {
		cout << "NEG_term -> term\n";
		}
	| identify L_PAREN EXP_term R_PAREN {
		cout << "NEG_term -> identify L_PAREN EXP_term R_PAREN\n";
		}
;

EXP_term:
	AS_expr EXP_after {
		cout << "EXP_term -> AS_expr COMMA EXP_term\n";
		}
	| AS_expr {
		cout << "EXP_term -> AS_expr\n";
		}
;

EXP_after:
	%empty {
		cout << "EXP_after -> epsilon\n";
		}
	| COMMA EXP_term {
		cout << "EXP_after -> COMMA EXP_term\n";
		}
;

term:
	var { 
		cout << "term -> var\n"; 
		}
	| var L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET {
		cout << "term -> var L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n";
		}
	| L_PAREN AS_expr R_PAREN {
		cout << "term -> L_PAREN AS_expr R_PAREN\n";
		}
	| NUMBER {
		cout << "var -> " << $1 << endl;
		}
;

vars:
	var COMMA vars {
		cout << "vars -> var COMMA vars\n";
		}
	| var {
		cout << "vars -> var\n";
		}
;

var:
	IDENT {
		cout << "var -> " << $1 << endl;
		}
	IDENT L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET {
		cout << "var -> " << $1 << " L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n";
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


%%

/*
	start -> functions
	functions -> function functions | epsilon
    function -> FUNCTION ident SEMICOLON parameters declarations parameters declarations parameters statements parameters
    parameters -> begin_params | end_params | begin_locals | end_locals | begin_body | end_body | parameters parameters
   	declarations -> declaration SEMICOLON declarations
   	declaration -> identify COLON INTEGER | identify COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
   	statements -> statement SEMICOLON statements | epsilon
   	statement -> var ASSIGN AS_expr | IF OR_expr THEN statements ENDIF | WHILE OR_expr statements ENDLOOP | DO BEGINLOOP statements ENDLOOP WHILE OR_expr | FOR var ASSIGN | READ vars | WRITE vars | CONTINUE | RETURN AS_expr 
   	OR_expr -> AND_expr OR OR_exp | AND_expr
   	AND_expr -> REL_expr AND AND_expr | REL_expr
   	REL_expr -> AS_expr comp AS_expr | L_PAREN OR_expr R_PAREN | TRUE | FALSE
   	comp -> GT | LT | GTE | LTE | EQ | NEQ
   	AS_expr -> MDM_expr | MDM_expr ADD AS_expr  MDM_expr SUB AS_expr 
   	MDM_expr -> NEG_term | NEG_term MOD MDM_expr | NEG_term MULT MDM_expr | NEG_term DIV MDM_expr
   	NEG_term -> SUB term | term identify L_PAREN EXP_term R_PAREN
   	term -> var | var L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET | L_PAREN AS_expr R_PAREN | NUMBER
   	var -> ident
   	ident -> IDENT
*/


int main() {
    yyparse();
}