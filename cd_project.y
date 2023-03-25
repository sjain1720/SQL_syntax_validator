%{
    #include<stdio.h>
	  void yyerror(const char* s);
%}

%token NUM
%token DATATYPE
%token CREATE
%token DROP
%token DATABASE
%token TABLE
%token NOT
%token NUL
%token FOREIGN
%token PRIMARY
%token KEY
%token REFERENCES
%token CONSTRAINT
%token ID

%%

S : CREATE C ';'
  | DROP D ';'
  ;
D : DATABASE ID
  | TABLE ID
  ;
C : DATABASE ID
  | TABLE ID '(' A ')'
  ;
A : Attr ',' Attr
  | Attr
  ;
Attr : ID DATATYPE NN FK
     | ID DATATYPE NN PK
     | CPK
     |CFK
     ;
NN : NOT NUL
   ;
PK : PRIMARY KEY
   ;
FK : FOREIGN KEY REFERENCES ID '(' ID ')'
   ;
CPK : CONSTRAINT ID PRIMARY KEY '(' COL ')'
    ;
CFK : CONSTRAINT ID FOREIGN KEY '(' COL ')' REFERENCES '(' COL ')'
    ;
COL : ID ',' COL
    | ID
    ;
%%

int main()
{
    printf("\nEnter the command: ");
    yyparse();
    printf("\n Given command is valid.\n");    
    return 0;
}

void yyerror(const char* s)
{
	printf("\nGiven statement is Invalid: %s\n",s);
  exit(0);
}
