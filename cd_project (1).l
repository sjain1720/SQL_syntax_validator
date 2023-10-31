%option yylineno
%{
    #include "y.tab.h"
    #include <stdlib.h>
    int yycolumn = 1;
    int line_no = 1;
    //macro for the track of column number per line and line number
    #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = line_no; \
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng; 

    void yyerror(char e[100]);
    void isNotSpecial(char c)
    /*function to check if some other special character is encountered
    then exit the parsing
    intput : character
    output : none
    */
    {
        if( c== ','|| c == ';'|| c == '('|| c == ')'|| c == '"')
        {
            return ;
        }
        printf("\nError : special '%c' character encountered \n",c);
        exit(0);
    }
%}

/* REGULAR DEFINITIONS */
INT ([iI][nN][tT][eE][gG][eE][rR])|([iI][nN][tT])
DOUBLE [dD][oO][uU][bB][lL][eE]
IMAGE [iI][mM][aA][gG][eE]
BIT [bB][iI][tT]
DATE [dD][aA][tT][eE]
TIME [tT][iI][mM][eE]
TEXT [tT][eE][xX][tT]
Identifier [_a-zA-Z][a-zA-Z0-9_]*
VARCHAR [vV][aA][rR][cC][hH][aA][rR]
CHAR [cC][hH][aA][rR]
BINARY [bB][iI][nN][aA][rR][yY]
FLOAT [fF][lL][oO][aA][tT]


DECIMAL [dD][eE][cC][iI][mM][aA][lL]
NUMERIC [nN][uU][mM][eE][rR][iI][cC]

%%

[ ]+      {yycolumn += yyleng; /* skip blanks and line changes*/}
[ \n]      { yycolumn = 1; line_no++;/* yycolumn is set to 1 for every new line encountered*/}
{INT}|{DOUBLE}|{IMAGE}|{BIT}|{DATE}|{TIME}|{TEXT}  { yylval = 1; return DATATYPE_A;}
{CHAR}|{VARCHAR}|{BINARY}|{FLOAT} {yylval = 1; return DATATYPE_B;}
{DECIMAL}|{NUMERIC} {yylval = 1; return DATATYPE_C;}
[cC][rR][eE][aA][tT][eE] {yylval = 1; return CREATE;}
[Dd][rR][oO][pP] {yylval = 1; return DROP;}
[dD][aA][tT][aA][bB][aA][sS][eE] {yylval = 1; return DATABASE ;}
[tT][aA][bB][lL][eE] {yylval = 1; return TABLE;}
[nN][oO][tT] {yylval = 1; return NOT;}
[nN][uU][lL][lL] {yylval = 1; return NULLL;}
[fF][oO][rR][eE][iI][gG][nN] {yylval = 1; return FOREIGN;}
[pP][rR][iI][mM][aA][rR][yY] {yylval = 1; return PRIMARY;}
[Uu][Nn][Ii][Qq][Uu][Ee] {yylval = 1; return UNIQUE;}
[kK][eE][yY] {yylval = 1; return KEY;}
[rR][eE][fF][eE][rR][eE][nN][cC][eE][sS] {yylval = 1; return REFERENCES;}
[cC][oO][nN][sS][tT][rR][aA][iI][nN][tT] {yylval = 1; return CONSTRAINT;}
[Dd][Ee][Ff][Aa][Uu][Ll][Tt] {yylval = 1; return DEFAULT;}
[0-9]+{Identifier} {yyerror("syntax error, ID must not start with number") ;}
[0-9]* {yylval = 1; return NUM;}
{Identifier}[.]{Identifier}[.]{Identifier} {return SchDBName;}
{Identifier}[.]{Identifier} {return DbName;}
{Identifier} {yylval = 1; return ID;}
. { isNotSpecial(yytext[0]); return yytext[0]; }

%%
int yywrap()
{
    return 1;
}