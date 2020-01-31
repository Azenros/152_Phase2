%{
  Prologue
%}

Bison declarations

%%


%%

/*
   function -> FUNCTION ident parameters locals parameters locals parameters

   locals -> 
   declarations -> idents colon integer
   idents -> ident between ident | ident exp ident
   ident -> number
   between -> comma | assign | and | or
   exp -> add | sub | mult | div | lte | gte | lt | gt | eq | neq | mod

   parameters -> begin_params | end_params | begin_locals | end_locals | begin_body | end_body |
                 parameters parameters
   

   

   
*/


int main() {
    yyparse();
}
