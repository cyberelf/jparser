%{

#include <stdio.h>
#include <string.h>
#define YYSTYPE char*
#include "junos.tab.h"

int oldstate;

%}

%x COMMENT

%%

#[^\r^\n]* ;
"/*" { oldstate = YY_START; BEGIN COMMENT; }
<COMMENT>"*/" { BEGIN oldstate; }
<COMMENT>.|\n ;
<COMMENT><<EOF>> { yyerror("unclosed comment"); }

[\{] {
  return O_BEGIN;
};

[\}] {
  return O_END;
};

[;] {
  return SEMICOLON;
}

"inactive:" {
  return INACTIVE;
}

\"(\\.|[^"])*\" {
    yylval=strdup(yytext);
    return STRING;
};

[[:alnum:]\[\]\<\*][^ ^\t^;^\r^\n]* {
  yylval=strdup(yytext); /* Do not identify array here because it has no syntax value */
  return WORD;
};

[ \t\n] ; /* whitespace */

. { yyerror("mystery character '%c'", *yytext); }

%%

int main(argc, argv)
int argc;
char **argv;
{
  if(argc > 1) {
    if(!(yyin = fopen(argv[1], "r"))) {
      perror(argv[1]);
      return (1);
    }
  }
  init(); 
  yyparse(); 
  fclose(yyin);
  return 0;
}
