%{
    #include "y.tab.h"
    YYSTYPE yylval;
%}

%%

[cC][rR][eE][aA][tT][eE] {return CREATE;}
[iI][nN][tT][eE][gG][eE][rR] {return DATATYPE;}
[iI][nN][tT] { return DATATYPE;}
[fF][lL][oO][aA][tT] {return DATATYPE;}
[dD][oO][uU][bB][lL][eE] {return DATATYPE;}
[vV][aA][rR][cC][hH][aA][rR] { return DATATYPE;}
[Dd][rR][oO][pP] {return DROP;}
[dD][aA][tT][aA][bB][aA][sS][eE] {return DATABASE ;}
[tT][aA][bB][lL][eE] {return TABLE;}
[nN][oO][tT] {return NOT;}
[nN][uU][lL][lL] {return NUL;}
[fF][oO][rR][eE][iI][gG][nN] {return FOREIGN;}
[pP][rR][iI][mM][aA][rR][yY] {return PRIMARY;}
[kK][eE][yY] {return KEY;}
[rR][eE][fF][eE][rR][eE][nN][cC][eE][sS] {return REFERENCES;}
[cC][oO][nN][sS][tT][rR][aA][iI][nN][tT] {return CONSTRAINT;}
[0-9]* {return NUM;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[;] {}
\n {return 0;}

%%

int yywrap()
{
    return 1;
}