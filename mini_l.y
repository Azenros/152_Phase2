%{
  #include <iostream>
  #include <stdio.h>
  #include <string>
  #include <string.h>
  #include <sstream>
  #include <vector>
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
  int ind = 0;
  
  map<string, int> variables;
  map<string, int> functions;
  
  string newString(string s);
  
  vector<string> reservedWords = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "FOREACH", "IN", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "AND", "OR", "NOT", "TRUE", "FALSE", "RETURN", "SUB", "ADD", "MULT", "DIV", "MOD", "EQ", "NEQ", "LT", "GT", "LTE", "GTE", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "COLON", "SEMICOLON", "COMMA", "ASSIGN", "function", "Ident", "beginparams", "endparams", "beginlocals", "endlocals", "integer", "beginbody", "endbody", "beginloop", "endloop", "if", "endif", "foreach", "continue", "while", "else", "read", "do", "write"};
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
%type <expr> OR_expr AND_expr REL_expr NOT_expr AS_expr MDM_expr NEG_term term term_ex comp declarations declaration identify vars var fident

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
        if (variables.find(prog) == functions.end()) {
            string s = "Program name declared as variable";
            yyerror(s);
        }
    }
;

function:
    FUNCTION fident SEMICOLON parameters declarations parameters declarations parameters statements parameters {
        //cout << "function -> FUNCTION fident SEMICOLON parameters declarations parameters declarations parameters statements parameters\n";
        ostringstream oss;
        string init = $5.code;
        string statements($9.code);
        int param_num = 0;
        oss << "func" << $2.place << "\n" << $2.code << init;

        while (init.find(".") != string::npos) {
            size_t pos = init.find(".");
            string param_str = ", $"; 
            init.replace(pos, 1, "=");
            param_str.append(to_string(param_num++));
            param_str.append("\n");
            init.replace(init.find("\n", pos), 1, param_str);
        }
        oss << init << $7.code;
        
        if (statements.find("continue") != string::npos) {
            cout << "Error: Continue outside loop in function " << $2.place << "\n";
        }
        oss << statements << "endfunc\n";
        
        string result = oss.str();
        cout << result;
    }
;

fident:
    IDENT {
        //cout << "fident -> IDENT " << $1 << endl;
        if (functions.find($1) != functions.end()) {
            ostringstream oss;
            oss << "Redeclaration of function " << $1;
            yyerror(oss.str());
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
        //cout << "parameters -> BEGIN_PARAMS\n"; 
    }
    | END_PARAMS BEGIN_LOCALS { 
        //cout << "parameters -> END_PARAMS BEGIN_LOCALS\n"; 
    }
    | END_LOCALS BEGIN_BODY { 
        //cout << "parameters -> END_LOCALS BEGIN_BODY\n"; 
    }
    | END_BODY { 
        //cout << "parameters -> END_BODY\n"; 
    }
;

declarations:
    declaration SEMICOLON declarations {
        //cout << "declarations -> declaration SEMICOLON declarations\n";
        ostringstream oss;
        oss << $1.code << $3.code;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
    | %empty { 
        //cout << "declarations -> epsilon\n"; 
        $$.code = strdup("");
        $$.place = strdup("");
    }
;

declaration:
    identify COLON INTEGER {
        //cout << "declaration -> identify COLON INTEGER\n"; 
        ostringstream oss;
        string vars($1.place);
        string fVar = "";
        bool reserved = false;
        bool con = true;
        size_t oPos = 0;
        size_t cPos = 0;
        
        while (con) {
            cPos = vars.find("|", oPos);
            if (cPos == string::npos) {
                fVar = vars.substr(oPos,cPos);
                con = false;
            }
            else {
                size_t length = cPos - oPos;
                fVar = vars.substr(oPos, length);
            }
            oss << ". " << fVar << "\n";
            
            for (unsigned i = 0; i < reservedWords.size(); i++) {
                if (fVar == reservedWords[i]) {
                    reserved = true;
                }
            }
            
            if (variables.find(fVar) != variables.end()) {
                ostringstream ess;
                ess << "Reclaration of variable " << fVar.c_str();
                yyerror(ess.str()); 
            }
            else if (reserved) {
                ostringstream ess;
                ess << "Invalid declaration of reserved words " << fVar.c_str();
                yyerror(ess.str());
            }
            else {
                variables.insert(pair<string,int>(fVar,0));
            }
            oPos = cPos++;
        }
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
    
    | identify COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
        //cout << "declaration -> identify COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"; 
        if ($5 <= 0) {
            ostringstream ess;
            ess << "Error: Array size cannot be less than 1";
            yyerror(ess.str());
        }
        
        ostringstream oss;
        string vars($1.place);
        string fVar = "";
        bool con = true;
        size_t oPos = 0;
        size_t cPos = 0;
        
        while (con) {
            cPos = vars.find("|", oPos);
            if (cPos == string::npos) {
                fVar = vars.substr(oPos,cPos);
                con = false;
            }
            else {
                size_t length = cPos - oPos;
                fVar = vars.substr(oPos, length);
            }
            oss << ".[] " << fVar << ", " << to_string($5) << "\n";
            
            if (variables.find(fVar) != variables.end()) {
                ostringstream ess;
                ess << "Reclaration of variable " << fVar.c_str();
                yyerror(ess.str()); 
            }
            else {
                variables.insert(pair<string,int>(fVar,$5));
            }
            oPos = cPos++;
        }
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
;

identify:
    IDENT {
        //cout << "identify -> IDENT " << $1 << endl;
        $$.code = strdup("");
        $$.place = strdup($1);
    }
    | IDENT COMMA identify {
        //cout << "identify -> IDENT " << $1 << " COMMA identify\n";
        ostringstream oss;
        oss << strdup($1) << "|" << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
;


statements:
    statement SEMICOLON statements {
        //cout << "statements -> statement SEMICOLON statements\n";
        ostringstream oss;
        oss << $1.code << $3.code;
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | statement SEMICOLON { 
        //cout << "statements -> statement SEMICOLON\n"; 
        ostringstream oss;
        oss << $1.code;
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
;

statement:
        var ASSIGN AS_expr {
        //cout << "statement -> var ASSIGN AS_expr\n"
        string vaa = $3.place; 
        ostringstream oss;
        oss << $1.code << $3.code;
        if ($1.is_array) { 
            oss << "[]="; 
        }
        else if ($3.is_array) {
            oss << "= ";
        }
        else { 
            oss << "= "; 
        }
        
        oss << $1.place << ", " << $3.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | IF OR_expr THEN statements ENDIF {
        //cout << "statement -> IF OR_expr THEN statements ENDIF\n";
        string ifor = newString("L");
        string post = newString("L");
        ostringstream oss;
        oss << $2.code << "?:= " << ifor << ", " << $2.place << "\n";
        oss << ":= " << post << "\n" << ": " << ifor << "\n";
        oss << $4.code << ": " << post << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | IF OR_expr THEN statements ELSE statements ENDIF {
        //cout << "statement -> IF OR_expr THEN statements ELSE statements ENDIF\n";
        string ifor = newString("L");
        string post = newString("L");
        ostringstream oss;
        oss << $2.code
            << "?:= " << ifor << ", " 
            << $2.place << "\n"
            << $6.code << ":= " << post << "\n"
            << ": " << ifor << "\n"
            << $4.code
            << ": " << post << "\n";
            
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | WHILE OR_expr BEGINLOOP statements ENDLOOP {
        //cout << "statement -> WHILE OR_expr BEGINLOOP statements ENDLOOP\n";
        string begin = newString("L");
        string state = newString("L");
        string end = newString("L");
        string code = $4.code;
        ostringstream oss;
        size_t position = code.find("continue");
        while (position != string::npos) {
            code.replace(position, 8, ":= " + begin);
            position = code.find("continue");
        }
        oss << ": " << begin << "\n" 
            << $2.code << "?: " << state << ", " 
            << $2.place << "\n" 
            << ":= " << end << "\n" 
            << ": " << state << "\n"
            << code << ":= " << begin << "\n" 
            << ": " << end << "\n";
            
        code = oss.str();    
        $$.code = strdup(code.c_str());
    }
    | DO BEGINLOOP statements ENDLOOP WHILE OR_expr {
        //cout << "statement -> DO BEGINLOOP statements ENDLOOP WHILE OR_expr\n";
        string begin = newString("L");
        string state = newString("L");
        string code = $3.code;
        ostringstream oss;
        size_t position = code.find("continue");
        while (position != string::npos) {
            code.replace(position, 8, ":= " + state);
            position = code.find("continue");
        }
        oss << ": " << begin << "\n" 
            << code << ": " << state << "\n"
            << $6.code << "?:= " << begin << ", " << $6.place << "\n";
        
        code = oss.str();    
        $$.code = strdup(code.c_str());
    }
    | FOR var ASSIGN NUMBER SEMICOLON OR_expr SEMICOLON var ASSIGN AS_expr BEGINLOOP statements ENDLOOP {
        //cout << "statement -> FOR var ASSIGN NUMBER SEMICOLON OR_expr SEMICOLON var Assign AS_expr BEGINLOOP statements ENDLOOP\n";
        string dst = newString("_t");
        
        string var = newString("L"); // condition
        string state = newString("L"); //inner
        string inc = newString("L"); // change me?  increment
        string end = newString("L"); //after
        string mid = to_string($4); //middle
        string code = $12.code;
        ostringstream oss;
        
        size_t position = code.find("continue"); // find at position value of continue
        while (position != string::npos) { // as long as its not the end of string
            code.replace(position, 8, ":= " + inc);
            position = code.find("continue");
        }
        
        oss << $2.code;
        
        if ($2.is_array) { 
            oss << "[]= "; 
        } 
        else { 
            oss << "= "; 
        }
        
        oss << $2.place << ", " << mid << "\n" 
            << ": " << var << "\n"
            << $6.code << "?:= " << state << ", " << $6.place << "\n" 
            << ":= " << end << "\n" 
            << ": " << state << "\n"
            << code << ": " << inc << "\n"
            << $8.code << $10.code;
            
        if ($8.is_array) { 
            oss << "[]= "; 
        } 
        else { 
            oss << "= "; 
        }
        
        oss << $8.place << ", " << $10.place << "\n"
            << ":= " << var << "\n"
            << ": " << end << "\n";
            
        code = oss.str();
        $$.code = strdup(code.c_str());
        
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
        ostringstream oss;
        oss << $2.code << "ret " << $2.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
		
;

OR_expr:
    OR_expr OR AND_expr {
        //cout << "OR_expr -> OR_expr OR AND_expr\n";
        ostringstream oss;
        string temp = newString("_t");
        oss << $1.code << $3.code << ". " << temp << "\n|| " << temp << ", " 
            << $1.place << ", " << $3.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp.c_str());
    }
    | AND_expr {
        //cout << "OR_expr -> AND_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
;

AND_expr:
    AND_expr AND NOT_expr {
        //cout << "AND_expr -> AND_expr AND NOT_expr\n";
        ostringstream oss;
        string temp = newString("_t");
        oss << $1.code << $3.code << ". " << temp << "\n&& " << temp << ", " 
            << $1.place << ", " << $3.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp.c_str());
    }
    | NOT_expr {
        //cout << "AND_expr -> NOT_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
;

NOT_expr:
    NOT REL_expr {
        //cout << "NOT_expr -> NOT REL_expr\n";
        ostringstream oss;
        string temp = newString("_t");
        oss << $2.code << ". " << temp << "\n! " 
            << temp << ", " << $2.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp.c_str());
    }
    | REL_expr {
        //cout << "NOT_expr -> REL_expr\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
;

REL_expr:
    AS_expr comp AS_expr {
        //cout << "REL_expr -> AS_expr comp AS_expr\n";
        ostringstream oss;
        string temp = newString("_t");
        oss << $1.code << $3.code << ". " << temp << "\n" << $2.place << temp 
            << ", " << $1.place << ", " << $3.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp.c_str());
    }
    | L_PAREN OR_expr R_PAREN {
        //cout << "REL_expr -> L_PAREN OR_expr R_PAREN\n";
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
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
        $$.place = strdup(">");
    }
    | LT {
        //cout << "comp -> LT\n";
        string cmp = "<";
        $$.code = strdup("");
        $$.place = strdup("<");
    }
    | GTE {
        //cout << "comp -> GTE\n";
        string cmp = ">=";
        $$.code = strdup("");
        $$.place = strdup(">=");
    }
    | LTE {
        //cout << "comp -> LTE\n";
        string cmp = "<=";
        $$.code = strdup("");
        $$.place = strdup("<=");
    }
    | EQ {
        //cout << "comp -> EQ\n";
        string cmp = "==";
        $$.code = strdup("");
        $$.place = strdup("==");
    }
    | NEQ {
        //cout << "comp -> NEQ\n";
        string cmp = "!=";
        $$.code = strdup("");
        $$.place = strdup("!=");
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
        ostringstream oss;
        oss << $1.code << $3.code << ". " << $$.place << "\n+ " << $$.place 
            << ", " << $1.place << ", " << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(newString("_t").c_str());

    }
    | MDM_expr SUB AS_expr { 
        //cout << "AS_expr -> MDM_expr SUB AS_expr\n";
        ostringstream oss;
        oss << $1.code << $3.code << ". " << $$.place << "\n- " << $$.place 
            << ", " << $1.place << ", " << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(newString("_t").c_str());
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
        ostringstream oss;
        oss << $1.code << $3.code << ". " << $$.place << "\n% " << $$.place 
            << ", " << $1.place << ", " << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(newString("_t").c_str());
    }
    | NEG_term MULT MDM_expr { 
        //cout << "MDM_expr -> NEG_term MULT MDM_expr\n";
        ostringstream oss;
        oss << $1.code << $3.code << ". " << $$.place << "\n* " << $$.place 
            << ", " << $1.place << ", " << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(newString("_t").c_str());
    }
    | NEG_term DIV MDM_expr	{ 
        //cout << "MDM_expr -> NEG_term DIV MDM_expr\n";
        ostringstream oss;
        oss << $1.code << $3.code << ". " << $$.place << "\n/ " << $$.place 
            << ", " << $1.place << ", " << $3.place;
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(newString("_t").c_str());
    }
;

NEG_term:
    SUB term { 
        //cout << "NEG_term -> SUB NEG_term\n";
        ostringstream oss;
        string temp = newString("_t");
        oss << $2.code << ". " << $$.place << "\n";
        if ($2.is_array) {
            oss << "=[] "; 
        }
        else {
            oss << "= "; 
        }
        oss << "* " << $$.place << ", " << $$.place << ", -1\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp.c_str());
        $$.is_array = false;
    }
    | term {
        //cout << "NEG_term -> NEG_term\n";
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | IDENT L_PAREN term_ex R_PAREN {
        //cout << "NEG_term -> IDENT L_PAREN term_ex R_PAREN \n";
        ostringstream oss;
        string temp = $1;
        string temp2 = newString("_t");
        if (functions.find(temp) == functions.end()) {
            oss << "Calling undeclared function " << temp;
            yyerror(oss.str());
        }
        oss << $3.code << ". " << temp2 << "\ncall " 
            << temp << ", " << temp2 << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup(temp2.c_str());
    }
;

term_ex:
    AS_expr COMMA term_ex {
        //cout << "term_ex -> AS_expr COMMA term_ex\n";
        ostringstream oss;
        oss << $1.code << "param " << $1.place << "\n" << $3.code;
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
    | AS_expr {
        //cout << "term_exp -> AS_expr\n";
        ostringstream oss;
        oss << $1.code << "param " << $1.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
;

term:
    var { 
        //cout << "term -> var\n"; 
        if ($$.is_array) {
            ostringstream oss;
            string n = newString("_t");
            oss << $1.code << ". " << n << "\n=[] " 
                << n << ", " << $1.place << "\n";
            string code = oss.str();
        
            $$.code = strdup(code.c_str());
            $$.place = strdup(n.c_str());
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

vars:
    var COMMA vars {
        //cout << "vars -> var COMMA vars\n";
        ostringstream oss;
        oss << $1.code;
        
        if ($1.is_array) {
            oss << ".[]| ";
        }
        else {
            oss << ".| ";
        }
        oss << $1.place << "\n" << $3.code;
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
    | var {
        //cout << "vars -> var\n";
        ostringstream oss;
        oss << $1.code;
        
        if ($1.is_array) {
            oss << ".[]| ";
        }
        else {
            oss << ".| ";
        }
        oss << $1.place << "\n";
        
        string code = oss.str();
        $$.code = strdup(code.c_str());
        $$.place = strdup("");
    }
;

var:
    IDENT {
        //cout << "var -> IDENT " << ($1) << endl;
        char emess[128] = "abc";
        if (variables.find($1) == variables.end()) {
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
        //cout << "var -> IDENT " << ($1) << " L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET\n";
        char emess[128] = "abc";
        if (variables.find((string)($1)) == variables.end()) {
            snprintf(emess,128,"Use of undeclared variable %s", $1);
            yyerror(emess);
        }
        else if (variables.find((string)($1))->second == 0) {
            snprintf(emess,128,"Indexing a non-array variable %s", $1);
            yyerror(emess);
        }
        ostringstream oss;
        oss << $1 << ", " << $3.place;
        string place = oss.str();
        $$.code = strdup($3.code);
        $$.place = strdup(place.c_str());
        $$.is_array = true;
    }
;

%%

string newString(string s) {
    string temp = s + to_string(ind);
    ind++;
    return temp;
}


int yyerror(string s) {
    extern int line, space;
    cout << "Error at line " << line << ", column " << space << ": " << s << endl;
    //exit(1);
    return 0;
} 
int yyerror(char* c) {
    return yyerror(string(c));
}
