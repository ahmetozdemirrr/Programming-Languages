/* %option noyywrap */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h" // interpreter generates this file
%}

COMMENT         [;]{2}.*
VALUEF          [0-9]+[b][1-9][0-9]*
IDENTIFIER      [a-zA-Z][a-zA-Z0-9]*


%%
    /* KEYWORDS */

true            { return KW_TRUE;     }
false           { return KW_FALSE;    }
and             { return KW_AND;      }
or              { return KW_OR;       }
not             { return KW_NOT;      }
equal           { return KW_EQUAL;    }
less            { return KW_LESS;     }
nil             { return KW_NIL;      }
list            { return KW_LIST;     }
append          { return KW_APPEND;   }
concat          { return KW_CONCAT;   }
set             { return KW_SET;      }
for             { return KW_FOR;      }
if              { return KW_IF;       }
load            { return KW_LOAD;     }
disp            { return KW_DISP;     }
exit            { return KW_EXIT;     }
def             { return KW_DEF;      }             

    /* OPERATORS */

[+]             { return OP_PLUS;     }
[-]             { return OP_MINUS;    }
[/]             { return OP_DIV;      }
[*]             { return OP_MULT;     }
[(]             { return OP_OP;       }
[)]             { return OP_CP;       }
[,]             { return OP_COMMA;    }

{COMMENT}       { return COMMENT; }
{IDENTIFIER}    { yylval.string = strdup(yytext); return IDENTIFIER; }
{VALUEF}        { yylval.string = strdup(yytext); return VALUEF; }


[ \t\n]  {;} // ignore spaces, tabs and newlines

.      
        { 
            printf("Syntax Error (Lexing)\n");
            exit(EXIT_FAILURE);
        }
%%