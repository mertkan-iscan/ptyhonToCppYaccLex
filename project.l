%{
#include <stdio.h>
#include <iostream>
#include <string.h>
#include "y.tab.h"
using namespace std;

%}

%%

=	return ASSIGNOP;

":" return COLON;
"if" return IFSTR;
"elif" return ELIFSTR;
"else" return ELSESTR;

[a-z]([a-z]|[0-9])*	{yylval.str = strdup(yytext); return VARIABLE;}

[0-9]+|-[0-9]+	{yylval.str = strdup(yytext); return INTEGER;}

\".+\" {yylval.str = strdup(yytext); return STRING;}

[0-9]+\.[0-9]+	{yylval.str = strdup(yytext); return FLOAT;}

\+|\-|\*|\/	{yylval.str = strdup(yytext); return MATHOP;}

\>|\<|"=="|"!="|"<="|">="	{yylval.str = strdup(yytext); return COMPOP;}

\t  {yylval.str = strdup(yytext); return TAB;}

[ \n]+
%%