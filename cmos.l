%{
#include <stdio.h>
#include <stdlib.h>

FILE *outfile;
%}

%option noyywrap nounput

%%

[ \t\n\r]+       { /* skip whitespace */ }
"//"[^\n]*       { /* skip single-line comment */ }

    /* Skip multi-line comments */
"/*"    {
            int c;
            while(1) {
                while ((c = input()) != '*' && c != EOF);
                if (c == EOF) break;
                do { c = input(); } while (c == '*');
                if (c == '/' || c == EOF) break;
            }
        }

    /* --- Keywords --- */
"if"        { fprintf(outfile, "001 "); }
"else"      { fprintf(outfile, "002 "); }
"while"     { fprintf(outfile, "003 "); }
"for"       { fprintf(outfile, "004 "); }
"return"    { fprintf(outfile, "005 "); }
"break"     { fprintf(outfile, "006 "); }
"continue"  { fprintf(outfile, "007 "); }
"switch"    { fprintf(outfile, "008 "); }
"case"      { fprintf(outfile, "009 "); }
"default"   { fprintf(outfile, "010 "); }
"do"        { fprintf(outfile, "011 "); }
"sizeof"    { fprintf(outfile, "012 "); }

    /* --- Data types --- */
"int"               { fprintf(outfile, "013 "); }
"char"              { fprintf(outfile, "014 "); }
"void"              { fprintf(outfile, "015 "); }
"float"|"double"    { fprintf(outfile, "016 "); }
"struct"            { fprintf(outfile, "017 "); }
"typedef"           { fprintf(outfile, "018 "); }
"enum"              { fprintf(outfile, "019 "); }
"union"             { fprintf(outfile, "020 "); }
"long"|"short"      { fprintf(outfile, "021 "); }
"unsigned"|"signed" { fprintf(outfile, "022 "); }
"static"|"extern"|"register"|"auto"  { fprintf(outfile, "023 "); }
"const"|"volatile"  { fprintf(outfile, "024 "); }

    /* --- Multi-character operators --- */
"=="                { fprintf(outfile, "025 "); }
"!="                { fprintf(outfile, "026 "); }
"<="                { fprintf(outfile, "027 "); }
">="                { fprintf(outfile, "028 "); }
"++"                { fprintf(outfile, "029 "); }
"--"                { fprintf(outfile, "030 "); }
"+=" | "-=" | "*=" | "/=" | "%="  { fprintf(outfile, "031 "); }
"&&"                { fprintf(outfile, "032 "); }
"||"                { fprintf(outfile, "033 "); }
"<<"                { fprintf(outfile, "034 "); }
">>"                { fprintf(outfile, "035 "); }
"->"                { fprintf(outfile, "036 "); }

    /* --- Single-character operators --- */
"="                 { fprintf(outfile, "037 "); }
"<"                 { fprintf(outfile, "038 "); }
">"                 { fprintf(outfile, "039 "); }
"+"                 { fprintf(outfile, "040 "); }
"-"                 { fprintf(outfile, "041 "); }
"*"                 { fprintf(outfile, "042 "); }
"/"                 { fprintf(outfile, "043 "); }
"%"                 { fprintf(outfile, "044 "); }
"!"                 { fprintf(outfile, "045 "); }
"&"                 { fprintf(outfile, "046 "); }
"|"                 { fprintf(outfile, "047 "); }

    /* --- Delimiters --- */
"{"     { fprintf(outfile, "048 "); }
"}"     { fprintf(outfile, "049 "); }
"("     { fprintf(outfile, "050 "); }
")"     { fprintf(outfile, "051 "); }
"["     { fprintf(outfile, "052 "); }
"]"     { fprintf(outfile, "053 "); }
";"     { fprintf(outfile, "054 "); }
","     { fprintf(outfile, "055 "); }
":"     { fprintf(outfile, "056 "); }

    /* --- Identifiers --- */
[a-zA-Z_][a-zA-Z0-9_]*    { fprintf(outfile, "057 "); }

    /* --- Literals --- */
[0-9]+                  { fprintf(outfile, "058 "); }
\"([^\"\\]|\\.)*\"      { fprintf(outfile, "059 "); }
\'([^\'\\]|\\.)*\'      { fprintf(outfile, "060 "); }

    /* --- Catch-all --- */
.                       { /* skip anything else */ }

%%

int main(void) {
    outfile = fopen("scanner_out.txt", "w");
    if (!outfile) {
        fprintf(stderr, "Error: cannot open scanner_out.txt\n");
        return 1;
    }
    yylex();
    fclose(outfile);
    return 0;
}