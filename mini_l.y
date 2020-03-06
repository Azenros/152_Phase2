%{
  #include <iostream>
  #include <stdio.h>
  #include <string>
  #include <string.h>
  #include <map>
  #include <stdlib.h>
  using namespace std;

  int yylex();
  int yyerror(string s);
  int yyerror(char* c);

  extern int line;
  extern int space;
  extern string prog;
  char epsilon[1] = "";
  
  map<string, int> variables;
  map<string, int> functions;
  
  string newString(string s);
  //scroll down for full grammar
%}

%union {
	int ival;
	char* sval;

	struct E {
	  char* place;
	  char* code;
      bool is_array;
	} expr;

	struct S {
	  char* code;
	} stat;
}
%error-verbose
%start start

%type <stat> statements statement
%type <expr> OR_expr AND_expr REL_expr NOT_expr AS_expr MDM_expr NEG_term term term_id term_ex term_exp comp declarations declaration declaration_2 identify vars var fident

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY FOR OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN
%token <ival> NUMBER
%token <sval> IDENT

%left AND OR 
%right NOT
%left ADD SUB
%left MULT DIV MOD 
%left EQ NEQ LT GT LTE GTE
%left ASSIGN


%%

start:
    program { 
        //cout << "start -> program\n"; 
    }
;

program:
    function program { 
        //cout << "program -> function\n"; 
    }
    | %empty { 
        //cout << "program -> epsilon\n";
        string tMain = "main";
        if (functions.find(tMain) == functions.end()) {
            string s = "Function main not declared";
            yyerror(s);
        }
        if (variables.find(prog) != functions.end()) {
            string s = "Program name declared as variable";
            yyerror(s);
        }
    }
;

function:
    FUNCTION fident SEMICOLON parameters declarations parameters declarations parameters statements parameters {
        cout << "function -> FUNCTION fident SEMICOLON parameters declarations parameters declarations parameters statements parameters\n"; 
    }
;

fident:
    IDENT {
        cout << "fident -> IDENT " << $1 << endl;
        char emess[128] = "abc";
        if (functions.find($1) != functions.end()) {
            snprintf(emess,128,"Redeclaration of function %s", $1);
            yyerror(emess);
        }
        else {
            functions.insert(pair<string,int>($1,0));
        }
        $$.code = strdup("");
        $$.place = strdup($1);
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
    | %empty { 
        cout << "declarations -> epsilon\n"; 
    }
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
    | READ vars {
        //cout << "statement -> READ vars\n";
        size_t in = 0;
        string re = $2.code;
        while (true) {
            in = re.find("|",in);
            if (in == string::npos) {
                break;
            }
            re.replace(in,1, "<");
        }
        $$.code = strdup(re.c_str());
    }
    | WRITE vars {
        //cout << "statement -> WRITE vars\n";
        size_t in = 0;
        string wr = $2.code;
        while (true) {
            in = wr.find("|",in);
            if (in == string::npos) {
                break;
            }
            wr.replace(in,1, ">");
        }
        $$.code = strdup(wr.c_str());
            
    }
    | CONTINUE {
        //cout << "statement -> CONTINUE\n";
        string con = "continue\n";
        $$.code = strdup(con.c_str());
    }
    | RETURN AS_expr {
        //cout << "statement -> RETURN AS_expr\n";
        string temp = $2.code;
        temp.append("ret ");
        temp.append($2.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
    }
		
;

OR_expr:
    OR_expr OR AND_expr {
        cout << "OR_expr -> OR_expr OR AND_expr\n";
    }
    | AND_expr {
        //cout << "OR_expr -> AND_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
;

AND_expr:
    AND_expr AND NOT_expr {
        cout << "AND_expr -> AND_expr AND NOT_expr\n";
    }
    | NOT_expr {
        //cout << "AND_expr -> NOT_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
;

NOT_expr:
    NOT REL_expr {
        cout << "NOT_expr -> NOT REL_expr\n";
    }
    | REL_expr {
        //cout << "NOT_expr -> REL_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
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
        //cout << "REL_expr -> TRUE\n";
        string t = "1";
        $$.code = strdup("");
        $$.place = strdup(t.c_str());
    }
    | FALSE {
        //cout << "REL_expr -> FALSE\n";
        string f = "0";
        $$.code = strdup("");
        $$.place = strdup(f.c_str());
    }
;

comp:
    GT {
        //cout << "comp -> GT\n";
        string cmp = ">";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
    | LT {
        //cout << "comp -> LT\n";
        string cmp = "<";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
    | GTE {
        //cout << "comp -> GTE\n";
        string cmp = ">=";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
    | LTE {
        //cout << "comp -> LTE\n";
        string cmp = "<=";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
    | EQ {
        //cout << "comp -> EQ\n";
        string cmp = "==";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
    | NEQ {
        //cout << "comp -> NEQ\n";
        string cmp = "!=";
        $$.code = strdup("");
        $$.place = strdup(cmp.c_str());
    }
;

AS_expr:
    MDM_expr { 
        //cout << "AS_expr -> MDM_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place); 
    }
    | MDM_expr ADD AS_expr { 
        //cout << "AS_expr -> MDM_expr ADD AS_expr\n";
        string code = $1.code;
        code.append($3.code);
        code.append(". ");
        code.append($$.place);
        code.append("\n+ ");
        code.append($$.place);
        code.append(", ");
        code.append($1.place);
        code.append(", ");
        code.append($3.place);
        $$.code = strdup(code.c_str());

    }
    | MDM_expr SUB AS_expr { 
        //cout << "AS_expr -> MDM_expr SUB AS_expr\n";
        string code = $1.code;
        code.append($3.code);
        code.append(". ");
        code.append($$.place);
        code.append("\n- ");
        code.append($$.place);
        code.append(", ");
        code.append($1.place);
        code.append(", ");
        code.append($3.place);
        $$.code = strdup(code.c_str());
    }
;

MDM_expr:
    NEG_term { 
        //cout << "MDM_expr -> NEG_term\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place); 
    }
    | NEG_term MOD MDM_expr { 
        //cout << "MDM_expr -> NEG_term MOD MDM_expr\n";
        string code = $1.code;
        code.append($3.code);
        code.append(". ");
        code.append($$.place);
        code.append("\n% ");
        code.append($$.place);
        code.append(", ");
        code.append($1.place);
        code.append(", ");
        code.append($3.place);
        $$.code = strdup(code.c_str());
    }
    | NEG_term MULT MDM_expr { 
        //cout << "MDM_expr -> NEG_term MULT MDM_expr\n";
        string code = $1.code;
        code.append($3.code);
        code.append(". ");
        code.append($$.place);
        code.append("\n* ");
        code.append($$.place);
        code.append(", ");
        code.append($1.place);
        code.append(", ");
        code.append($3.place);
        $$.code = strdup(code.c_str());
    }
    | NEG_term DIV MDM_expr	{ 
        //cout << "MDM_expr -> NEG_term DIV MDM_expr\n";
        string code = $1.code;
        code.append($3.code);
        code.append(". ");
        code.append($$.place);
        code.append("\n/ ");
        code.append($$.place);
        code.append(", ");
        code.append($1.place);
        code.append(", ");
        code.append($3.place);
        $$.code = strdup(code.c_str());
    }
;

NEG_term:
    SUB term { 
        cout << "NEG_term -> SUB NEG_term\n";
    }
    | term {
        //cout << "NEG_term -> NEG_term\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | IDENT term_id {
        cout << "NEG_term -> IDENT term_id \n";
    }
;

term:
    var { 
        //cout << "term -> var\n"; 
        if ($$.is_array) {
            string code = newString("_t");
            string place = $1.code;
            place.append(". ");
            place.append(code);
            place.append("\n=[] ");
            place.append(code);
            place.append(", ");
            place.append($1.place);
            place.append("\n");
            $$.code = strdup(code.c_str());
            $$.place = strdup(place.c_str());
            $$.is_array = false;            
        }
        else {
            $$.code = strdup($1.code);
            $$.place = strdup($1.place);
        }
    }
    | L_PAREN AS_expr R_PAREN {
        //cout << "term -> L_PAREN AS_expr R_PAREN\n";
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
    }
    | NUMBER {
        //cout << "term -> NUMBER " << ($1) << endl;
        $$.code = strdup("");
        $$.place = strdup(to_string($1).c_str());
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
    AS_expr term_exp {
        cout << "term_ex -> AS_expr COMMA term_exp\n";
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
    var COMMA vars {
        cout << "vars -> var COMMA vars\n";
    }
    | var {
        cout << "vars -> var\n";
    }
;

var:
    IDENT {
        //cout << "var -> IDENT " << ($1) << endl;
        char emess[128] = "abc";
        if (variables.find($1) != variables.end()) {
            snprintf(emess,128,"Redeclaration of variable %s", $1);
            yyerror(emess);
        }
        else {
            variables.insert(pair<string, int>((string)$1, 0));
        }
        $$.code = strdup("");
        $$.place = strdup($1);
    }
    | IDENT L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET {
        cout << "var -> IDENT " << ($1) << " L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n";
    }
;

%%

string newString(string s) {
    static int index = 0;
    string temp = s + to_string(index++);
    return temp;
}


int yyerror(string s) {
    extern int line, space;
    cout << "Error at line " << line << ", column " << space << ": " << s << endl;
    exit(1);
    return 0;
} 
int yyerror(char* c) {
    return yyerror(string(c));
}
