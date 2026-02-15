%{

#include <stdio.h>
#include <string.h>

int codeLine = 1;
int position = 1;

void print_token(const char* type, const char* value) {
    printf("Token(%s, '%s', line=%d, pos=%d)\n", 
           type, value, codeLine, position);
}
%}


DIGIT       [0-9]
LETTER      [a-zA-Z]
ID_START    ({LETTER}|_)
ID_CONT     ({LETTER}|{DIGIT}|_)
ID          {ID_START}{ID_CONT}*


INT         {DIGIT}+
FRACTION    ({DIGIT}*"."{DIGIT}+)|({DIGIT}+"."{DIGIT}*)
EXP         [eE][+-]?{DIGIT}+
SCIENTIFIC  ({INT}|{FRACTION}){EXP}
FLOAT       ({FRACTION})({EXP})?
HEX         0[xX][0-9a-fA-F]+

ESC         \\([nt"\\])
STRING      \"({ESC}|[^"\\])*\"

WHITESPACE  [ \t\r]+
%x COMMENT

%%


"+"         { print_token("PLUS", yytext); position += yyleng; }
"-"         { print_token("MINUS", yytext); position += yyleng;}
"*"         { print_token("TIMES", yytext); position += yyleng;}
"/"         { print_token("DIVIDE", yytext); position += yyleng;}

"=="                { print_token("EQ", yytext); position += yyleng; }
"!="                { print_token("NEQ", yytext); position += yyleng; }
"<="                { print_token("LE", yytext); position += yyleng; }
">="                { print_token("GE", yytext); position += yyleng; }
"<"                 { print_token("LT", yytext); position += yyleng; }
">"                 { print_token("GT", yytext); position += yyleng; }


"&&"                { print_token("AND", yytext); position += yyleng; }
"||"                { print_token("OR", yytext); position += yyleng; }
"!"                 { print_token("NOT", yytext); position += yyleng; }

"//".*              { position += yyleng;}
"/*"                { BEGIN(COMMENT); position += yyleng;}

<COMMENT>{
    "*/"            {BEGIN(INITIAL); position += yyleng;}
    \n              { codeLine++; position =1;}
    .               { position += yyleng;}

}

{ID}                { print_token("IDENTIFIER", yytext); position += yyleng; }
{HEX}               { print_token("HEX", yytext); position += yyleng; }
{SCIENTIFIC}        { print_token("SCIENTIFIC", yytext); position += yyleng; }
{FLOAT}             { print_token("FLOAT", yytext); position += yyleng; }
{INT}               { print_token("INT", yytext); position += yyleng; }

{STRING}            { print_token("STRING", yytext); position += yyleng; }
{WHITESPACE}        { position += yyleng; }

\n                  { codeLine++; position = 1; }

. {
    printf("ERROR: Unknown character '%s' at line %d, position %d\n",
           yytext, codeLine, position);
    position += yyleng;
}

%%

int yywrap() { return 1; }

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Cannot open file: %s\n", argv[1]);
            return 1;
        }
    }

    yylex();

    if (argc > 1) fclose(yyin);
    return 0;
}