%{
  #include<fcntl.h> //for read write system calls 
  #include <stdlib.h> //for memory allocations and deallocations
  #include <stdio.h> //for standard input output 

  extern char *yytext;
  int valid=1, name_provided= 1, datatype_provided = 1;
  int yylex(void);
  //int yerrstatus = 0;
  void yyerror(char *e);  //required to check what is in the current input token read by parser
  void checkCommaError();
  void checkTableName();
  void checkAttributeName();
  void checkFKconstraintName();
  void checkPKconstraintName();
  int command_start_line = 1; //to track command starting line useful to distinguish multiple commands
  int command_start_col = 1;  //to track command starting column useful to distinguish multiple commands

  void read_file(char *fname)
  /* function to read and display command from file provided 
  input : filename|path
  output : void */
  {
      int fd = open(fname, O_RDONLY);
      char c[1];
      printf("\nGiven String :\n");
      while(read(fd,c,1)>0)
      {
          write(1,c,1);
      }
      printf("\n\n");
      //closing the file
      fd=close(fd);
  }

%}
%locations
%error-verbose
%token DATATYPE_A DATATYPE_B DATATYPE_C 
%token CREATE DROP 
%token DATABASE
%token TABLE
%token NOT NULLL/*token for null*/
%token UNIQUE PRIMARY FOREIGN DEFAULT
%token KEY
%token REFERENCES
%token CONSTRAINT
%token ID SchDBName DbName NUM
%%


/*start of grammar rules */
S : {command_start_line = yylloc.first_line; command_start_col = yylloc.first_column;} CREATE C Semicolon  S
  | {command_start_line = yylloc.first_line; command_start_col = yylloc.first_column;} DROP  D Semicolon  S
  |/*empty*/
  ;
// Error recovery i user misses to write semicolon
Semicolon : ';' { if( valid == 1) printf("\nGiven command from line %d:%d-%d:%d is valid!!\n",command_start_line,command_start_col,yylloc.last_line,yylloc.last_column); valid = 1;  /*for case when user enters multiple command*/}
          | { if( yychar == 0) {yyerror("missing semicolon(;).");} else {yyerror("you might be missing semicolon(;) or there is a syntax error.\nMisleading syntax, parsing stopped!!!"); }  exit(0);}
          ;
// rules for drop database | table
D : DATABASE SingleDBName      { if( name_provided == 0)  yyerror("you missed Database name."); }
  | TABLE SingleTableName    { if( name_provided == 0)  yyerror("you missed table name."); }           
  | DATABASE NUM             { yyerror("invalid database name,expecting Identifier number provided");} //rule when number is passed as database name
  | TABLE NUM                { yyerror("invalid table name,expecting Identifier number provided");}  //rule when number is passed as table name
  | DATABASE mulDBName         { yyerror("multiple DATABASE name provided, command requires only 1."); }  /*to handle multiple name errors*/
  | TABLE mulTableName       { yyerror("multiple TABLE name provided, command requires only 1.");  }    /*to handle multiple name errors*/
  ;
/*here we have duplication in rules because we want to be sepcific what error to show
database name missing or table name? , multiple name for database or table..
*/
C : DATABASE SingleDBName  { if( name_provided == 0)  yyerror("you missed database name."); }
  | DATABASE mulDBName     { yyerror("multiple Database name provided, command requires only 1.");  }       {/*to handle multiple name errors*/}
  | TABLE  SingleTableName { if( name_provided == 0){ checkTableName(); yyerror("you missed table name.");} } '('  A {checkCommaError(); } ')'     
  | TABLE  mulTableName  { yyerror("multiple TABLE name provided, command requires only 1.");  } '(' A {checkCommaError(); } ')'
  ;
//grammar rules when multiple table name are provided in place of 1
mulTableName :  ID DbName
  | DbName DbName
  | ID ID
  | SchDBName DbName
  | DbName SchDBName
  | SchDBName ID
  | ID SchDBName 
  | SchDBName SchDBName
  | DbName ID
  |  ID mulTableName
  | DbName mulTableName
  | SchDBName mulTableName 
  ;
//grammar rules for table name 
SingleTableName : ID   { name_provided = 1;  } 
  | DbName   { name_provided = 1;  }
  | SchDBName  { name_provided = 1;  }
  | /*empty*/     { name_provided = 0;  }
  ;
//grammar rules for database name 
SingleDBName : ID   { name_provided = 1;  } 
  | DbName   { name_provided = 1;  }
  | /*empty*/     { name_provided = 0;  }
  ;
//grammar rules for multiple database name 
mulDBName : DbName DbName  
  | ID ID
  | DbName ID
  | ID DbName
  | ID mulDBName
  | DbName mulDBName
  ;
//grammar rule for attribute and database name and all other that reuired ID
SingleName : ID   { name_provided = 1;  } 
  | /*empty*/     { name_provided = 0;  }
  ;
mulName : ID mulName //grammar rule when multiple attribute and database name and all other that reuired ID
  | ID ID 
  ;
//rule for attributes declaration of tables
A : Attr ',' A
  | Attr /*for the last attribute which don't require ',' */
  | error //to handle errors raised by invalid tokens during attribute declaration 
  ;
Attr : SingleName   { if( name_provided == 0) { checkAttributeName(); yyerror("you missed attribute name");}}  DAT {  if(name_provided==0 && datatype_provided==0){yyerror("Invalid attribute declaration\nMisleading syntax, parsing stopped!!!");exit(0);}} NN Unq PK FK  DF
     | mulName      { yyerror("multiple attribute name provided, command requires only 1.");  } DAT NN Unq PK FK DF
     | NUM          { { yyerror("Invalid attribute name,expecting Identifier number provided");}}  DAT {  if(name_provided==0 && datatype_provided==0){yyerror("Invalid attribute declaration\nMisleading syntax, parsing stopped!!!");exit(0);}} NN Unq PK FK  DF
     | CPK    //non terminal for primary key constraint
     | CFK    //non terminal for foreign key constraint
     ;
// rule for datatypes 
DAT : DATATYPE_A                      {datatype_provided = 1; }
    | DATATYPE_B '(' NUM ')'            {datatype_provided = 1; }
    | DATATYPE_C '(' NUM COMMA NUM ')'  {datatype_provided = 1; }
    | /*error*/                       {datatype_provided = 0;yyerror("missing datatype.");} 
    ;
NN : NOT NULLL {}
   | /*empty*/ {}
   ;
//rule for primnAry key
PK : PRIMARY KEY {}
   | /*empty*/ {}
  ;
//rule for unique key
Unq : UNIQUE
    |/*empty*/
    ;
//rule for foreign key 
FK : FOREIGN KEY REFERENCES SingleTableName {if( name_provided == 0){ checkTableName(); yyerror(" missed table name for Reference");}} '(' SingleName {if( name_provided == 0)  yyerror("missed column name for references.");} ')' 
   | /*empty*/ 
   ;
//rule for default 
DF : DEFAULT Val
   | /*empty*/
   ;
//rule for default values it can be a string value(ID) , function() or an integer(NUM) 
Val : NUM 
    | ID '(' ')'
    | '"' ID '"'
    | '"' NUM '"'
    ;
//grammar rules for primary constraint
CPK : CONSTRAINT SingleName  {if( name_provided == 0){checkPKconstraintName(); yyerror("missing constraint name ");}} PRIMARY KEY '(' COL ')'
    | CONSTRAINT mulName  {yyerror("multiple constraint name provided, command requires only 1.");} PRIMARY KEY '(' COL ')'
    ;
//grammar rules for foreign key constraint
CFK : CONSTRAINT SingleName  {if( name_provided == 0){checkFKconstraintName(); yyerror("missing constraint name ");}} FOREIGN KEY '(' COL ')' REFERENCES SingleTableName {if( name_provided == 0){ checkTableName(); yyerror("you missed table name.");}} '(' COL ')' 
    | CONSTRAINT mulName  {yyerror("multiple constraint name provided, command requires only 1.");} FOREIGN KEY '(' COL ')' REFERENCES SingleTableName {if( name_provided == 0){ checkTableName(); yyerror("you missed table name.");}} '(' COL ')'
    ;
//grammar rule for defining multiple columns seprated by comma for constraint
COL : ID COMMA COL { /*COL.count = COL1.count + 1;*/}
    | ID         { /*COL.count = 1;*/}
    ;
//rule for error recovery is user misses comma(,)
COMMA : ','
    | /* error */ {yyerror("missing comma.");}
    ;
%%

int main()
/*main method to start our opeartions */
{
  read_file("a1.sql");
  extern FILE *yyin;
  yyin = fopen("a1.sql","r");

  //yyout = fopen("b.cpp","w");//used for debugging
  yyparse();
  return 0;
}

void yyerror(char e[100])
/*error function to handle errors and display proper message with error location
input : char array of size 100 
output : void */
{
  char s[12] = "syntax error";
  int diff = 0;
  /*we want to terminate the parsing process when such a input is encountered from where 
  there is no error recovery rules procedure Mode */
  for( int i =0; i < 12; i++)
  {
    if( e[i] != s[i]) /*to check if error generated by parser starts with 'syntax error'
     then diff will remain 0,so that we can exit the parsing because going ahaed will mislead parser
     as there might be no error recovery rules for that*/
    {
      diff = 1;
      break;
    }
  }
  if( diff == 0)
  {
    printf("\nERROR at %d:%d-%d : %s \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,e);
    printf("\nMisleading syntax, parsing stopped!!!\n");
    exit(0);
  }
  printf("\nERROR at %d:%d-%d : %s \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,e);
  valid = 0; // means command is not valid, it has some errors
  //printf("%d",yychar == CREATE);
  //exit(0);
}

void checkCommaError()
/* to check for comma missing
input : void
output : void
*/
{
  if(yychar != ')'&&yychar != ';'  && yychar != EOF)
  {
    yyerror("syntax error, unexpected token, expecting ','");
  }
  return ;
}

void checkTableName()
/* to check for name error for table
input : void
output : void
*/
{
  if(yychar != '(' && yychar != ID && yychar != DATATYPE_A && yychar != DATATYPE_B && yychar != DATATYPE_C)
  {
    printf("\nERROR at %d:%d-%d : syntax error, unexpected %s, expecting Identifier \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,yytext);
    exit(0);
  }
  return ;
}
void checkAttributeName()
/* to check for name error for attribute name
input : void
output : void
*/
{
  if(yychar != ','  && yychar != DATATYPE_A && yychar != DATATYPE_B && yychar != DATATYPE_C)
  {
    printf("\nERROR at %d:%d-%d : syntax error, unexpected %s, expecting Identifier  \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,yytext);
    exit(0);
  }
  return ;
}
void checkPKconstraintName()
/* to check for name error for primary key constraint 
input : void
output : void
*/
{
  if(yychar != PRIMARY)
  {
    printf("\nERROR at %d:%d-%d : syntax error, unexpected %s, expecting Identifier  \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,yytext);
    exit(0);
  }
  return ;
}
void checkFKconstraintName()
/* to check for name error for foreign key constraint 
input : void
output : void
*/
{
  if(yychar != FOREIGN)
  {
    printf("\nERROR at %d:%d-%d : syntax error, unexpected %s, expecting Identifier  \n",yylloc.first_line,yylloc.first_column,yylloc.last_column,yytext);
    exit(0);
  }
  return ;
}