%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>

    #define YYSTYPE char*
    #define MAX_LEVEL 32
    #define SET "set"
    #define DEACTIVATE "deactivate"

    void print_cfg(const char* str);
    void print_deactive_cfg(const char* str);
    typedef struct {
      int cur_kw;
      char* keywords[MAX_LEVEL];
    } kwstack;
    kwstack g_kws;
%}

%token WORD STRING O_BEGIN O_END SEMICOLON INACTIVE

%%

START: STATEMENTS;

STATEMENTS: STATEMENT | STATEMENTS STATEMENT;

STATEMENT: TERMLINE
| BLOCK_BEGIN STATEMENTS BLOCK_END
;

TERMLINE: VALUES SEMICOLON {
    //printf ("Termline %s\n", $1);
    print_cfg($1);
    free($1);
  }
| INACTIVE VALUES SEMICOLON {
    print_deactive_cfg($2);
    print_cfg($2);
    free($2);
  }
;

BLOCK_BEGIN: VALUES O_BEGIN {
    //printf ("Block begins %s\n", $1);
    g_kws.cur_kw++;
    g_kws.keywords[g_kws.cur_kw] = $1;
  }
| INACTIVE VALUES O_BEGIN {
    //deactivaed config
    g_kws.cur_kw++;
    g_kws.keywords[g_kws.cur_kw] = $2;
    print_deactive_cfg("");
  }
;
BLOCK_END: O_END {
    free(g_kws.keywords[g_kws.cur_kw]);
    g_kws.keywords[g_kws.cur_kw] = NULL;
    g_kws.cur_kw--;
  }
;

VALUES: WORD {
    //printf ("Word %s\n", $1); 
    $$=$1;
  }
| STRING {
    //printf ("String %s\n", $1);
    $$=$1;
  } 
| VALUES WORD {
    //printf ("Multi Values %s %s\n", $1, $2);
    $$ = (char *)malloc(sizeof(char)*(strlen($1)+1+strlen($2)+1));
    sprintf($$,"%s %s",$1,$2);
    free($1);
    free($2);
  }
| VALUES STRING {
    //printf ("Multi Values %s %s\n", $1, $2);
    $$ = (char *)malloc(sizeof(char)*(strlen($1)+1+strlen($2)+1));
    sprintf($$,"%s %s",$1,$2);
    free($1);
    free($2);
  }
;

%%
int init()
{
    g_kws.keywords[0] = strdup(SET);
    g_kws.cur_kw = 0;
    return 0;
}
int yywrap()
{
    return 1;
}
int yyerror (char *err) {  
    fprintf(stderr, "%s", err);  
}
void print_cfg(const char* str)
{
    int i=0;
    for (;i<=g_kws.cur_kw;i++) {
          printf("%s ", g_kws.keywords[i]);
    }
    printf("%s\n", str);
}
void print_deactive_cfg(const char* str)
{
    int i=1;
    printf("%s", DEACTIVATE);
    for (;i<=g_kws.cur_kw;i++) {
          printf(" %s", g_kws.keywords[i]);
    }
    printf(" %s\n", str);
}
