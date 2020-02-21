%{
  //#include <iostream>
  //using namespace std;  
  
  int line = 1;
  int space = 0;
  //scroll down for full grammar
%}

%token NUMBER
%token IDENT
%token NEQ
%token LTE
%token LT
%token GTE
%token GT
%token EQ
%token FUNCTION
%token SEMICOLON
%token BEGIN_PARAMS






%%
start: 
	functions { printf("Start -> functions\n"); }
;

functions: 
	function functions { 
		printf("functions -> function functions\n"); 
		}
	| %empty { 
		printf("functions -> epsilon\n"); 
		}
;

function:
	 function IDENT SEMICOLON parameters declarations parameters declarations parameters statements parameters {
		printf("function -> FUNCTION" << $2 << "SEMICOLON parameters declarations parameters declarations parameters statements parameters\n"); 
		}
;

parameters:
	BEGIN_PARAMS { 
		printf("parameters -> BEGIN_PARAMS\n"); 
		}
	| "END_PARAMS" "BEGIN_LOCALS" { 
		printf("parameters -> END_PARAMS BEGIN_LOCALS\n"); 
		}
	| "END_LOCALS" "BEGIN_BODY" { 
		printf("parameters -> END_LOCALS BEGIN_BODY\n"); 
		}
	| "END_BODY" { 
		printf("parameters -> END_BODY\n"); 
		}
;

declarations:
	declaration "SEMICOLON" declarations {
		printf("declarations -> declaration SEMICOLON declarations\n"); 
		}
;

declaration:
	identify "COLON" "INTEGER" {
		printf("declaration -> identify COLON INTEGER\n"); 
		}
	| identify "COLON" "ARRAY" "L_SQUARE_BRACKET" NUMBER "R_SQUARE_BRACKET" "OF" "INTEGER" {
		printf("declaration -> identify COLON ARRAY L_SQUARE_BRACKET " << $5 << " R_SQUARE_BRACKET OF INTEGER\n"); 
		}
;


statements:
	%empty
	| statement "SEMICOLON" statements {
		printf("statements -> statement SEMICOLON statements\n");
		}
;

statement:
	var "ASSIGN" AS_expr {
		printf("statement -> var ASSIGN AS_expr\n");
		}
	| "IF" OR_expr "THEN" statements "ENDIF" {
		printf("statement -> IF OR_expr THEN statements ENDIF\n");
		}
	| "WHILE" OR_expr statements "ENDLOOP" {
		printf("statement -> WHILE OR_expr statements ENDLOOP\n");
		}
	| "DO" "BEGINLOOP" statements "ENDLOOP" "WHILE" OR_expr {
		printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE OR_expr\n");
		}
	| "FOR" var "ASSIGN"  {
		printf("statement -> FOR var ASSIGN\n");
		}
	| "READ" vars {
		printf("statement -> READ vars\n");
		}
	| "WRITE" vars {
		printf("statement -> WRITE vars\n");
		}
	| "CONTINUE" {
		printf("statement -> CONTINUE\n");
		}
	| "RETURN" AS_expr {
		printf("statement -> RETURN AS_expr\n");
		}
		
;

OR_expr:
	AND_expr "OR" OR_expr {
		printf("OR_expr -> AND_expr OR OR_expr\n");
		}
	| AND_expr {
		printf("OR_expr -> AND_expr\n");
		}
;

AND_expr:
	REL_expr "AND" AND_expr {
		printf("AND_expr -> NOT_expr AND AND_expr\n");
		}
	| REL_expr {
		printf("AND_expr -> NOT_expr\n");
		}
;

NOT_expr:
	"NOT" REL_expr {
		printf("NOT_expr -> NOT REL_expr\n");
		}
	| REL_expr {
		printf("NOT_expr -> REL_expr\n");
		}
;

REL_expr:
	AS_expr comp AS_expr {
		printf("REL_expr -> AS_expr comp AS_expr\n");
		$$ = $1 $2 $3;
		}
	| "L_PAREN" OR_expr "R_PAREN" {
		printf("REL_expr -> L_PAREN OR_expr R_PAREN\n");
		}
	| "TRUE" {
		printf("REL_expr -> TRUE\n");
		$$ = 1;
		}
	| "FALSE" {
		printf("REL_expr -> FALSE\n");
		$$ = 0;
		}
;

AS_expr:
	MDM_expr { 
		printf("AS_expr -> MDM_expr\n"); 
		}
	| MDM_expr "ADD" AS_expr { 
		printf("AS_expr -> MDM_expr ADD AS_expr\n");
		$$ = $1 + $3; 
		}
	| MDM_expr "SUB" AS_expr { 
		printf("AS_expr -> MDM_expr SUB AS_expr\n"); 
		$$ = $1 - $3;
		}
;

MDM_expr:
	NEG_term { 
		printf("MDM_expr -> NEG_term\n"); 
		}
	| NEG_term "MOD" MDM_expr { 
		printf("MDM_expr -> NEG_term MOD MDM_expr\n"); 
		$$ = $1 % $3;
		}
	| NEG_term "MULT" MDM_expr { 
		printf("MDM_expr -> NEG_term MULT MDM_expr\n"); 
		$$ = $1 * $3;
		}
	| NEG_term "DIV" MDM_expr	{ 
		printf("MDM_expr -> NEG_term DIV MDM_expr\n"); 
		$$ = $1 / $3;
		}
;

NEG_term:
	"SUB" term { 
		printf("NEG_term -> SUB term\n");
		}
	| term {
		printf("NEG_term -> term\n");
		}
	| identify "L_PAREN" EXP_term "R_PAREN" {
		printf("NEG_term -> identify L_PAREN EXP_term R_PAREN\n");
		}
;

EXP_term:
	AS_expr "COMMA" EXP_term {
		printf("EXP_term -> AS_expr COMMA EXP_term\n");
		}
	| AS_expr {
		printf("EXP_term -> AS_expr\n");
		}
;

term:
	var { 
		printf("term -> var\n"); 
		}
	| var "L_SQUARE_BRACKET" AS_expr "R_SQUARE_BRACKET" {
		printf("term -> var L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n");
		$$ = $1[$3];
		}
	| "L_PAREN" AS_expr "R_PAREN" {
		printf("term -> L_PAREN AS_expr R_PAREN\n");
		}
	| NUMBER {
		printf("var -> ", $1);
		}
;

vars:
	var "COMMA" vars {
		printf("vars -> var COMMA vars\n");
		}
	| var {
		printf("vars -> var\n");
		}
;

var:
	IDENT {
		printf("var -> ", $1, "\n");
		}
	IDENT "L_SQUARE_BRACKET" AS_expr "R_SQUARE_BRACKET" {
		printf("var -> " << $1 << " L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n");
		}
;

identify:
	IDENT {
		printf("identify -> " << $1 << endl);
		}
	IDENT "COMMA" identify{
		printf("identify -> "  << $1 << " COMMA identify\n");
		}
;

comp:
	"GT" {
		printf("comp -> GT\n");
		}
	| "LT" {
		printf("comp -> LT\n");
		}
	| "GTE" {
		printf("comp -> GTE\n");
		}
	| "LTE" {
		printf("comp -> LTE\n");
		}
	| "EQ" {
		printf("comp -> EQ\n");
		}
	| "NEQ" {
		printf("comp -> NEQ\n");
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
