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
  void yyerror(const char* c);
 

  extern int line;
  extern int space;
  extern string prog;
  extern char* yytext;
  char empty[1] = "";
  int ind = 0;
  
  string newTemp();
  string newLabel();
  string newString(string s);
  
  map<string, int> variables;
  map<string, int> functions;
  
  string newString(string s);
  std::vector<string> reservedWords = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "FOR", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "AND", "OR",  "NOT", "TRUE", "FALSE", "RETURN", "SUB", "ADD", "MULT", "DIV", "MOD", "EQ", "NEQ", "LT", "GT", "LTE", "GTE", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "COLON", "SEMICOLON", "COMMA", "ASSIGN", "function", "ident", "beginparams", "endparams", "beginlocals", "endlocals", "integer", "beginbody", "endbody", "beginloop", "endloop", "if", "endif", "for", "continue", "while", "else", "read", "do", "write"};
  //scroll down for full grammar
%}


%union{
  char* sval;
  int ival;
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

%type <stat> statements statement statement_else
%type <expr> OR_expr AND_expr REL_expr NOT_expr AS_expr MDM_expr NEG_term term term_ex comp declarations declaration identify vars var fident ident

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY FOR OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN

%token <ival> NUMBER
%token <sval> IDENT

%left AND OR 
%right NOT
%left ADD SUB
%left MULT DIV MOD 
%left EQ NEQ LTE GTE LT GT 
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
        if (variables.find(prog) != variables.end()) {
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
        oss << "func " << $2.place << "\n" << $2.code << init;

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
        oss << statements << "endfunc\n\n";
        
        string result = oss.str();
        cout << result;
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
    //fixme
    string vars($1.place);
    string temp;
    string variable;
    bool cont = true;

    // Build list of declarations base on list of identify
    // identify use "|" as delimeter
    size_t oldpos = 0;
    size_t pos = 0;
    bool isReserved = false;
    while (cont) {
        pos = vars.find("|", oldpos);
        if (pos == string::npos) {
            temp.append(". ");
            variable = vars.substr(oldpos,pos);
            temp.append(variable);
            temp.append("\n");
            cont = false;
        }
        else {
            size_t len = pos - oldpos;
            temp.append(". ");
            variable = vars.substr(oldpos, len);
            temp.append(variable);
            temp.append("\n");
        }
        //check for reserved keywords (test 05)
        for (unsigned int i = 0; i < reservedWords.size(); ++i) {
            if (reservedWords.at(i) == variable) {
                isReserved = true;
            }
        } 
        // Check for redeclaration (test 04) TODO same name as program
        if (variables.find(variable) != variables.end()) {
            char temp[128];
            snprintf(temp, 128, "Redeclaration of variable %s", variable.c_str());
            yyerror(temp);
        }
        else if (isReserved){
            char temp[128];
            snprintf(temp, 128, "Invalid declaration of reserved words %s", variable.c_str());
            yyerror(temp);
        }
        else {
            variables.insert(std::pair<string,int>(variable,0));
        }
        
        oldpos = pos + 1;
    }
    
    $$.code = strdup(temp.c_str());
    $$.place = strdup(empty);	    
          
    }
    | identify COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
        // Check if declaring arrays of size <= 0 (test 08)
        if ($5 <= 0) {
            char temp[128];
            snprintf(temp, 128, "Array size can't be less than 1");
            yyerror(temp);
        }
        
        string vars($1.place);
        string temp;
        string variable;
        bool cont = true;

        // Build list of declarations base on list of identify
        // identify use "|" as delimeter
        size_t oldpos = 0;
        size_t pos = 0;
        while (cont) {
            pos = vars.find("|", oldpos);
            if (pos == string::npos) {
                temp.append(".[] ");
                variable = vars.substr(oldpos, pos);
                temp.append(variable);
                temp.append(", ");
                temp.append(std::to_string($5));
                temp.append("\n");
                cont = false;
            }
            else {
                size_t len = pos - oldpos;
                temp.append(".[] ");
                variable = vars.substr(oldpos, len);
                temp.append(variable);
                temp.append(", ");
                temp.append(std::to_string($5));
                temp.append("\n");
            }
            // Check for redeclaraion (test 04)
            if (variables.find(variable) != variables.end()) {
                char temp[128];
                snprintf(temp, 128, "Redeclaration of variable %s", variable.c_str());
                yyerror(temp);
            }
            else {
                variables.insert(std::pair<string,int>(variable,$5));
            }
              
            oldpos = pos + 1;
        }
        
        $$.code = strdup(temp.c_str());
        $$.place = strdup(empty);	      
    }
;



identify:     ident
{
  $$.place = strdup($1.place);
  $$.code = strdup("");
}
| ident COMMA identify
{ 
  ostringstream oss;
  oss << $1.place << "|" << $3.place;
  $$.place = strdup(oss.str().c_str());
  $$.code = strdup("");
}

statements:      
    statement SEMICOLON statements { 
        ostringstream oss;
        oss << $1.code << $3.code;
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | statement SEMICOLON {
        ostringstream oss;
        oss << $1.code;
        string code = oss.str();
        $$.code = strdup(code.c_str());
    };

    statement:      
        var ASSIGN AS_expr {
            ostringstream oss;
            string vaa = $3.place;
            oss << $1.code << $3.code; 
            if ($1.is_array && $3.is_array) {
                vaa = newTemp();//newString("__temp__");
                oss << ". " << vaa << "\n=[] " << vaa 
                    << ", " << $3.place << "\n[]= ";
            }
            else if ($1.is_array) {
                oss << "[]= ";
            }
            else if ($3.is_array) {
                oss << "=[] ";
            }
            else {
                oss << "= ";
            }
            oss << $1.place << ", " << vaa << "\n";

            $$.code = strdup(oss.str().c_str());
        }
    | IF OR_expr THEN statements statement_else ENDIF {
        string ifor = newLabel();//newString("__label__");
        string post = newLabel();//newString("__label__");
        ostringstream oss;

        oss << $2.code << "?:= " << ifor << ", " << $2.place << "\n"
            << ":= " << post << "\n" 
            << ": " << ifor << "\n"
            << $4.code << ": " << post << "\n";

        string code = oss.str();
        $$.code = strdup(code.c_str());
    }		 
    | WHILE OR_expr BEGINLOOP statements ENDLOOP {
          string begin = newLabel();//newString("__label__");
          string state = newLabel();//newString("__label__");
          string end = newLabel();//newString("__label__");
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
          string begin = newLabel();//newString("__label__");
          string state = newLabel();//newString("__label__");
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
        cout << "statement -> FOR var ASSIGN NUMBER SEMICOLON OR_expr SEMICOLON var Assign AS_expr BEGINLOOP statements ENDLOOP\n";
        string dst = newString("__temp__");
        
        string var = newString("__label__");
        string state = newString("__label__"); 
        string inc = newString("__label__"); // change me? 
        string end = newString("__label__"); 
        string mid = to_string($4); 
        string code = $12.code;
        ostringstream oss;
        
        size_t position = code.find("continue"); 
        while (position != string::npos) {
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


statement_else:   
    %empty {
        $$.code = strdup(empty);
    }
    | ELSE statements {
        $$.code = strdup($2.code);
    }
;

OR_expr:
    OR_expr OR AND_expr {
        //cout << "OR_expr -> OR_expr OR AND_expr\n";
        ostringstream oss;
        string temp = newTemp();//newString("__temp__");
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
        string temp = newTemp();//newString("__temp__");
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
        string temp = newTemp();//newString("__temp__");
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
        string temp = newTemp();//newString("__temp__");
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
        $$.place = strdup("> ");
    }
    | LT {
        //cout << "comp -> LT\n";
        string cmp = "<";
        $$.code = strdup("");
        $$.place = strdup("< ");
    }
    | GTE {
        //cout << "comp -> GTE\n";
        string cmp = ">=";
        $$.code = strdup("");
        $$.place = strdup(">= ");
    }
    | LTE {
        //cout << "comp -> LTE\n";
        string cmp = "<=";
        $$.code = strdup("");
        $$.place = strdup("<= ");
    }
    | EQ {
        //cout << "comp -> EQ\n";
        string cmp = "==";
        $$.code = strdup("");
        $$.place = strdup("== ");
    }
    | NEQ {
        //cout << "comp -> NEQ\n";
        string cmp = "!=";
        $$.code = strdup("");
        $$.place = strdup("!= ");
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
        $$.place = strdup(newTemp().c_str());
        oss << $1.code << $3.code << ". " << $$.place << "\n+ " << $$.place 
            << ", " << $1.place << ", " << $3.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());

    }
    | MDM_expr SUB AS_expr { 
        //cout << "AS_expr -> MDM_expr SUB AS_expr\n";
        ostringstream oss;
        $$.place = strdup(newTemp().c_str());
        oss << $1.code << $3.code << ". " << $$.place << "\n- " << $$.place 
            << ", " << $1.place << ", " << $3.place << "\n";
        string code = oss.str();
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
        ostringstream oss;
        $$.place = strdup(newTemp().c_str());
        oss << $1.code << $3.code << ". " << $$.place << "\n% " << $$.place 
            << ", " << $1.place << ", " << $3.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | NEG_term MULT MDM_expr { 
        //cout << "MDM_expr -> NEG_term MULT MDM_expr\n";
        ostringstream oss;
        $$.place = strdup(newTemp().c_str());
        oss << $1.code << $3.code << ". " << $$.place << "\n* " << $$.place 
            << ", " << $1.place << ", " << $3.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
    | NEG_term DIV MDM_expr	{ 
        //cout << "MDM_expr -> NEG_term DIV MDM_expr\n";
        ostringstream oss;
        $$.place = strdup(newTemp().c_str());
        oss << $1.code << $3.code << ". " << $$.place << "\n/ " << $$.place 
            << ", " << $1.place << ", " << $3.place << "\n";
        string code = oss.str();
        $$.code = strdup(code.c_str());
    }
;

NEG_term:
    SUB term {
        //cout << "NEG_term -> SUB term\n";
        ostringstream oss;
        string temp = newString("__temp__");
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
        //cout << "NEG_term -> term\n";
        $$.code = $1.code;
        $$.place = $1.place;
    }
    | ident L_PAREN term_ex R_PAREN {
       // Check for use of undeclared function (test 2)
          ostringstream oss;
          string temp = $1.place;
          string temp2 = newString("__temp__");
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

term:
    var { 
        //cout << "term -> var\n"; 
        if ($$.is_array) {
            ostringstream oss;
            string n = newString("__temp__");
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

// used only for function calls
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
    | %empty {
        //cout << "term_exp -> epsilon\n";
        $$.code = strdup("");
        $$.place = strdup("");
    }
;

vars:            
    var {
        string temp;
        temp.append($1.code);
        if ($1.is_array) {
            temp.append(".[]| ");
        }
        else {
            temp.append(".| ");
        }
        temp.append($1.place);
        temp.append("\n");

        $$.code = strdup(temp.c_str());
        $$.place = strdup(empty);
    }
    | var COMMA vars {
      string temp;
      temp.append($1.code);
      if ($1.is_array)
        temp.append(".[]| ");
      else
        temp.append(".| ");
      
      temp.append($1.place);
      temp.append("\n");
      temp.append($3.code);
      
      $$.code = strdup(temp.c_str());
      $$.place = strdup(empty);
    };


var:             
    ident L_SQUARE_BRACKET AS_expr R_SQUARE_BRACKET {
        ostringstream oss;
        // Check for use of undeclared variable (test 01)
        if (variables.find(string($1.place)) == variables.end()) {
            oss << "Use of undeclared variable " << $1.place;
            yyerror(oss.str());
        }
        // Check for use of single value as array (test 07)
        else if (variables.find(string($1.place))->second == 0) {
            oss << "Indexing a non-array variable " << $1.place;
            yyerror(oss.str());
        }
        oss << $1.place << ", " << $3.place;

        string place = oss.str();
        $$.code = strdup($3.code);
        $$.place = strdup(place.c_str());
        $$.is_array = true;
    }
    | ident {
        ostringstream oss;
        
        if (variables.find(string($1.place)) == variables.end()) {
          oss << "Use of undeclared variable " << $1.place;
          yyerror(oss.str());
        }
        
        else if (variables.find(string($1.place))->second > 0) {
          oss << "Failed to provide index for array variable " << $1.place;
          yyerror(oss.str());
        }

        $$.code = strdup(empty);
        $$.place = strdup($1.place);
        $$.is_array = false;
    }
;

ident:      
    IDENT {
        $$.code = strdup(empty);
        $$.place = strdup($1);
    }
;

fident: 
    IDENT {
        if (functions.find(string($1)) != functions.end()) {
          char temp[128];
          snprintf(temp, 128, "Redeclaration of function %s", $1);
          yyerror(temp);
        }
        else {
          functions.insert(std::pair<string,int>($1,0));
        }
        $$.place = strdup($1);
        $$.code = strdup(empty);
    }
;
%%

int yyerror(string s) {
    extern int line, space;
    cout << "Error at line " << line << ", column " << space << ": " << s << endl;
    //exit(1);
    return 0;
} 

void yyerror(const char* s) {
   //printf("ERROR: %s at symbol \"%s\" on line %d, col %d\n", s, yytext, line, space);
   yyerror(string(s));
}

string newTemp() {
  static int num = 0;
  string temp = "__temp__" + std::to_string(num++);
  return temp;
}

string newString(string s) {
    static int num = 0;
    string temp = s + to_string(num++);
    return temp;
}

string newLabel() {
  static int num = 0;
  string temp = "__label__" + std::to_string(num++);
  return temp;
}
		 

 
