%{
    #include<stdio.h>
    #include<stdlib.h>

    typedef enum
    {
        OP_PLUS = 1, OP_MINUS, OP_MULT, OP_DIV, OP_OP, OP_CP, OP_COMMA,
        VALUEI, VALUEF, IDENTIFIER, WHITESPACE, KW_TRUE, KW_FALSE, KW_AND,
        KW_OR, KW_NOT, KW_EQUAL, KW_LESS, KW_NIL, KW_LIST, KW_APPEND, KW_CONCAT, 
        KW_SET, KW_FOR, KW_IF, KW_LOAD, KW_DISP, KW_EXIT, KW_DEF
    }typeOfToken;
%}

/*regular expressions*/

VALUEI          [0-9]+
VALUEF          [0-9]+[b][0-9]+
IDENTIFIER      [a-zA-Z][a-zA-Z0-9]*
WHITESPACE      [ \t\n]+
MYSIGN          [^+-/*(), \n\t]             
COMMENT         ";;".*          
WHITESPACES     [\\t\\n]+                   

/*Operators and Keywords*/

%%
[+]                                         { return OP_PLUS;    }
[-]                                         { return OP_MINUS;   }
[*]                                         { return OP_MULT;    }
[/]                                         { return OP_DIV;     }
[(]                                         { return OP_OP;      }
[)]                                         { return OP_CP;      }
[,]                                         { return OP_COMMA;   }

true                                        { return KW_TRUE;     }
false                                       { return KW_FALSE;    }
and                                         { return KW_AND;      }
or                                          { return KW_OR;       }
not                                         { return KW_NOT;      }
equal                                       { return KW_EQUAL;    }
less                                        { return KW_LESS;     }
nil                                         { return KW_NIL;      }
list                                        { return KW_LIST;     }
append                                      { return KW_APPEND;   }
concat                                      { return KW_CONCAT;   }
set                                         { return KW_SET;      }
for                                         { return KW_FOR;      }
if                                          { return KW_IF;       }
load                                        { return KW_LOAD;     }
disp                                        { return KW_DISP;     }
exit                                        { return KW_EXIT;     }
def                                         { return KW_DEF;      }

{IDENTIFIER}                                { return IDENTIFIER; }
{VALUEF}                                    { return VALUEF; }
{VALUEI}                                    { return VALUEI; }
{COMMENT}                                   { printf("COMMENT\n"); }
{WHITESPACE}                                ;
{WHITESPACES}                               ;

{MYSIGN}+[a-zA-Z0-9]+                       { fprintf(stderr, "SYNTAX_ERROR '%s' cannot be tokenized\n",yytext); exit(1);}          
{MYSIGN}+[a-zA-Z0-9]+{MYSIGN}+              { fprintf(stderr, "SYNTAX_ERROR '%s' cannot be tokenized\n",yytext); exit(1);}         
.                                           { fprintf(stderr, "SYNTAX_ERROR '%s' cannot be tokenized\n",yytext); exit(1);}
%%

int main() /*main function*/
{
    int control;

    while(control = yylex())
    {
        switch (control)
        {
            case 1:
                printf("OP_PLUS\n");
                break;
            case 2:
                printf("OP_MINUS\n");
                break;
            case 3:
                printf("OP_MULT\n");
                break;
            case 4:
                printf("OP_DIV\n");
                break;
            case 5:
                printf("OP_OP\n");
                break;        
            case 6:
                printf("OP_CP\n");
                break;        
            case 7:
                printf("OP_COMMA\n");
                break;        
            case 8:
                printf("VALUEI\n");
                break;           
            case 9:
                printf("VALUEF\n");
                break;                      
            case 10:
                printf("IDENTIFIER\n");
                break;           
            case 11:
                printf("WHITESPACE\n");
                break;           
            case 12:
                printf("KW_TRUE\n");
                break;           
            case 13:
                printf("KW_FALSE\n");
                break;           
            case 14:
                printf("KW_AND\n");
                break;           
            case 15:
                printf("KW_OR\n");
                break;           
            case 16:
                printf("KW_NOT\n");
                break;           
            case 17:
                printf("KW_EQUAL\n");
                break;           
            case 18:
                printf("KW_LESS\n");
                break;           
            case 19:
                printf("KW_NIL\n");
                break;           
            case 20:
                printf("KW_LIST\n");
                break;           
            case 21:
                printf("KW_APPEND\n");
                break;           
            case 22:
                printf("KW_CONCAT\n");
                break;           
            case 23:
                printf("KW_SET\n");
                break;                      
            case 24:
                printf("KW_FOR\n");
                break;           
            case 25:
                printf("KW_IF\n");
                break;           
            case 26:
                printf("KW_LOAD\n");
                break;           
            case 27:
                printf("KW_DISP\n");
                break;           
            case 28:
                printf("KW_EXIT\n");
                break;           
            case 29:
                printf("KW_DEF\n");
                break;   
            default:
                break;
        }
    }
    return 0;
}