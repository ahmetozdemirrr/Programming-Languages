%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    
    extern FILE * yyin; // for printing to file
    int type = 0; // For evaluating VALUEF or IDENTIFIER

    typedef struct valuefSides /* Struct for VALUEF format */
    {
        int first;
        char middle;
        int second;
    }
    Numbers;

    typedef struct Function /* Struct for all functions to be defined */
    {
        char * name;
        char * operation;
        char * content;
    }
    Functions;
    
    typedef struct List /* Struct for all lists to be defined */
    {
        char * name;
        char ** elements;
        int size;
    }
    Lists;

    typedef struct Variable /* Struct for all variables to be defined */
    {
        char * name;
        char * content;
        //Lists * lists;
    }
    Variables;

    /************** FUNCTIONS DECLARATIONS **************/
    int yylex(); 
    int gcd (int a, int b);
    int yyerror(const char *a);
    int getVarIndex(char * a);
    int getLıstIndex(char * a);
    int getFunctionIndex(char * a);
    void freeMemory();
    void dispList(char * a);
    void setVar(char * a, char * b);
    void setList(char * a, char ** b);
    void createFunction(int x, char * a, char * b);
    char * processNot(char * a);
    char * getVarContent(char * a);
    char * isLess(char * a, char * b);
    char * isEqual(char * a, char * b);
    char * processOr(char * a, char * b);
    char * processAnd(char * a, char * b);
    char * evaluateOperator(char * a, char * b, char * c);
    char * getFunctionValue(int x, char * a, char * b, char * c);
    Numbers atomiseValuef (char * a);
    /****************************************************/

    int yyerror(const char *error) /* Error for syntax error */
    {
        printf("Syntax Error!\n");
        exit(EXIT_FAILURE);
    }

    Numbers atomiseValuef(char * str) /* Function for separate VALUEF sides */
    {
        int divided;
        int divider;
        char midChar;
        Numbers numbers;

        sscanf(str, "%d%c%d", &divided, &midChar, &divider);
        
        numbers.first = divided;
        numbers.second = divider;
        numbers.middle = midChar;

        return numbers;
    }

    int gcd (int n1, int n2) /* We use GCD to simplify and write the results of the operation. */
    {
        while (n2 != 0)
        {
            int temp = n2;

            n2 = n1 % n2;

            n1 = temp;
        }
        return n1;
    }

    Functions * functions = NULL; // We keep the defined functions in this array.
    Variables * variables = NULL; // We keep the defined variables in this array.
    //Lists * lists = NULL; // We keep the defined lists in this arrat. 
    int functionCount = 0; // Variable holding the number of functions defined
    int variableCount = 0; // Variable holding the number of variables defined
    //int listCount = 0; // Variable holding the number of lists defined

    /*
    void setList(char * name_, char ** elements_)
    {
        int isExist = getLıstIndex(name_);
        int elementNumber = 0;

        while (elements_[elementNumber] != NULL)
        {
            elementNumber++;
        }
        
        lists = realloc(lists, (listCount + 1) * sizeof(Lists));

        if (lists != NULL && isExist == -1)
        {
            lists[listCount].name = strdup(name_);
            lists[listCount].size = elementNumber;

            lists[listCount].elements = malloc((elementNumber + 1) * sizeof(char *));

            for (int i = 0; i < elementNumber; ++i)
            {
                lists[listCount].elements[i] = strdup(elements_[i]);
            }
            lists[listCount].elements[elementNumber] = NULL;
            listCount++;
        }
    }

    int getLıstIndex(char * listName)
    {
        for (int i = 0; i < listCount; ++i)
        {
            if (strcmp(listName, lists[i].name) == 0)
            {
                return i;
            }
        }
        return -1;
    }

    void dispList(char * listName)
    {
        int index = getLıstIndex(listName);

        printf("( ");
        for (int i = 0; i < lists[index].size; ++i)
        {
            printf(" %s ", lists[index].elements[i]);
        }
        printf(" )");
    }
    */
    
    void createFunction(int flag, char * name_, char * operation_) /* In order to call functions in runtime, we keep the defined functions in memory. */
    {
        int isExist = getFunctionIndex(name_);

        functions = realloc(functions, (functionCount + 1) * sizeof(Functions));

        if (functions != NULL && isExist == -1)
        {
            functions[functionCount].name      = strdup(name_);
            functions[functionCount].operation = strdup(operation_);

            if (flag == 1)
            {
                functions[functionCount].content = strdup(operation_);
            }
            printf("#function\n");

            functionCount++;
        }

        else if (isExist != -1)
        {
            fprintf(stderr, "Error: This function is already exist.\n");
            exit(EXIT_FAILURE);
        }

        else
        {
            fprintf(stderr, "Error: Memory allocation failed.\n");
            exit(EXIT_FAILURE);
        }
        type = 0;
    } 

    int getFunctionIndex(char * funcName) /* We return the position of the function in the array. */
    {
        for (int i = 0; i < functionCount; ++i)
        {
            if (strcmp(funcName, functions[i].name) == 0)
            {
                return i;
            }
        }
        return -1;
    }

    char * evaluateOperator(char * operator, char * param1, char * param2) /* We apply the operation that the function will do. */
    {
        char * result = NULL;

        if (strcmp(operator, "OP_PLUS") == 0) /* Summation operator */
        {
            int num1, num2, num3, num4; 
            
            Numbers nums1 = atomiseValuef(param1);
            Numbers nums2 = atomiseValuef(param2);

            num1 = nums1.first;
            num2 = nums1.second;
            num3 = nums2.first;
            num4 = nums2.second;

            int part1 = (num1 * num4) + (num2 * num3);
            int part2 = num2 * num4;

            int gcd_ = gcd(part1, part2);

            result = (char *)malloc(20);

            sprintf(result, "%db%d", part1 / gcd_, part2 / gcd_);
            printf("%s\n",result);

            return result;
        }

        else if (strcmp(operator, "OP_MINUS") == 0 && param2 != NULL) /* Substraction operator */
        {
            int num1, num2, num3, num4; 
                                                
            Numbers nums1 = atomiseValuef(param1);
            Numbers nums2 = atomiseValuef(param2);

            num1 = nums1.first;
            num2 = nums1.second;
            num3 = nums2.first;
            num4 = nums2.second;

            int part1 = (num1 * num4) - (num2 * num3);
            int part2 = num2 * num4;

            int gcd_ = gcd(part1, part2);

            result = (char *)malloc(20);

            sprintf(result, "%db%d", part1 / gcd_, part2 / gcd_);
            printf("%s\n",result);

            return result;
        }

        else if (strcmp(operator, "OP_MULT") == 0) /* Multplication operator */
        {
            int num1, num2, num3, num4; 
            
            Numbers nums1 = atomiseValuef(param1);
            Numbers nums2 = atomiseValuef(param2);

            num1 = nums1.first;
            num2 = nums1.second;
            num3 = nums2.first;
            num4 = nums2.second;

            int part1 = num1 * num3;
            int part2 = num2 * num4;

            int gcd_ = gcd(part1, part2);

            result = (char *)malloc(20);

            sprintf(result, "%db%d", part1 / gcd_, part2 / gcd_);
            printf("%s\n",result);

            return result;
        }

        else if (strcmp(operator,"OP_DIV") == 0) /* Dividing operator */
        {
            int num1, num2, num3, num4; 
            
            Numbers nums1 = atomiseValuef(param1);
            Numbers nums2 = atomiseValuef(param2);

            num1 = nums1.first;
            num2 = nums1.second;
            num3 = nums2.first;
            num4 = nums2.second;

            if (num3 == 0)
            {
                fprintf(stderr, "Zero division error (%s)\n",param2);
                exit(EXIT_FAILURE);
            }

            int part1 = num1 / num3;
            int part2 = num2 / num4;

            int gcd_ = gcd(part1, part2);

            result = (char *)malloc(20);

            sprintf(result, "%db%d", part1 / gcd_, part2 / gcd_);
            printf("%s\n",result);

            return result;
        }

        else if (strcmp(operator, "OP_MINUS") == 0 && param2 == NULL) /* Negative operator */
        {
            int num1, num2; 
                                                
            Numbers nums1 = atomiseValuef(param1);

            num1 = nums1.first;
            num2 = nums1.second;

            num1 = -num1;

            result = (char *)malloc(20);

            sprintf(result, "%db%d", num1, num2);
            printf("%s\n",result);

            return result;
        }

        else if (param1 == NULL && param2 == NULL)
        {
            return operator;
        }
        free(result);

        type = 0;

        return NULL;
    }

    char * getFunctionValue(int flag, char * funcName, char * param1, char * param2) /* We process the called function. */
    {
        int index = getFunctionIndex(funcName);

        if (index == -1)
        {
            fprintf(stderr, "Error: This function is (%s) not defined.\n", funcName);
            exit(EXIT_FAILURE);
        }

        else
        {
            if (flag == 1)
            {
                printf("%s\n", functions[index].content);
                return functions[index].content;
            }

            else
            {
                return evaluateOperator(functions[index].operation, param1, param2);                
            }
        }
    }

    int getVarIndex(char * varName) /* We return the position of the function in the array */
    {
        for (int i = 0; i < variableCount; ++i)
        {
            if (strcmp(varName, variables[i].name) == 0)
            {
                return i;
            }
        }
        return -1;
    }

    void setVar(char * name_, char * content_) /* Varible created function */
    {
        int index = getVarIndex(name_);

        variables = realloc(variables, (variableCount + 1) * sizeof(Variables));

        if (variables != NULL && index == -1)
        {
            variables[variableCount].name = strdup(name_);

            if (strcmp(content_,"nil") == 0)
            {
                variables[variableCount].content = NULL;
            }
            
            else
            {
                variables[variableCount].content = content_;
            }
            variableCount++;
        }

        else if (index != -1)
        {
            free(variables[index].content);
            
            if (strcmp(content_,"nil") == 0)
            {
                variables[index].content = NULL;
            }

            else
            {
                variables[index].content = content_;
            }
        }

        else
        {
            fprintf(stderr, "Error: Memory allocation failed.\n");
            exit(EXIT_FAILURE);
        }
    }

    char * getVarContent(char * varName) /* We return the position of the variable in the array. */
    {
        int divided;
        int divider;
        char midChar;
        
        if ((sscanf(varName, "%d%c%d", &divided, &midChar, &divider) == 3) || (strcmp(varName, "true") == 0) || (strcmp(varName, "false") == 0) || (strcmp(varName, "nil") == 0)) /* Eğer gelen değer zaten bir VALUEF ise bir variable değilse direkt olarak kendisini döndür. */
        {
            return varName;
        }

        else
        {
            int index = getVarIndex(varName);

            if (index == -1)
            {
                fprintf(stderr, "Error: This variable is (%s) not defined.\n",varName);
                exit(EXIT_FAILURE);
            }

            else
            {
                return variables[index].content;
            }
        }
    }

    char * processNot(char * operand) /* Boolean NOT operator */
    {
        if (strcmp(operand, "true") == 0)
        {
            return "false";
        }

        else
        {
            return "true";
        }
    }

    char * processAnd(char * operand1, char * operand2) /* Boolean AND operator */
    {
        if ((strcmp(operand1, "true") == 0) && (strcmp(operand2, "true") == 0))
        {
            return "true";
        }
        return "false";
    }

    char * processOr(char * operand1, char * operand2) /* Boolean OR operator */
    {
        if ((strcmp(operand1, "true") == 0) || (strcmp(operand2, "true") == 0))
        {
            return "true";
        }
        return "false";
    }

    char * isEqual(char * operand1, char * operand2) /* Checking equality of variable */
    {
        if (strcmp(operand1, operand2) == 0)
        {
            return "true";
        }
        return "false";
    }

    char * isLess(char * operand1, char * operand2) /* Checking compare situation (less) of given variables */
    {
        int num1, num2, num3, num4; 
            
        Numbers nums1 = atomiseValuef(operand1);
        Numbers nums2 = atomiseValuef(operand2);

        num1 = nums1.first;
        num2 = nums1.second;
        num3 = nums2.first;
        num4 = nums2.second;
        
        /* We equalise the denominators and check the less */
        int base1 = num2;    
        int base2 = num4;  

        if ((num1 * base2) < (num2 * base1))
        {
            return "true";
        }

        else
        {
            return "false";
        }
    }

    void freeMemory() /* Free memory */
    {
        free(functions);
        free(variables);
    }
%}  

%union 
{
    char * string;
    char values[1000][10];
}

%token <string> OP_PLUS OP_MINUS OP_MULT OP_DIV OP_OP OP_CP OP_COMMA COMMENT KW_DEF KW_DISP KW_TRUE KW_FALSE KW_LOAD VALUEF
%token <string> KW_AND KW_OR KW_NOT KW_EQUAL KW_LESS KW_NIL KW_LIST KW_APPEND KW_CONCAT KW_SET KW_FOR KW_IF KW_EXIT IDENTIFIER
%type  <string> INPUT EXP FUNCTION
%start START

%% /* CFG RULES START*/
    START:  
        /*Empty Expression */
        |   START INPUT
        ;

    INPUT:

            EXP                             {  $$ = $1;                                           }
        |   FUNCTION                        {  $$ = $1;                                           }
        |   COMMENT                         {  printf("COMMENT\n");                               }     
        |   OP_OP KW_EXIT OP_CP             {  freeMemory(); printf("$_\n"); exit(EXIT_FAILURE);  }
        ;

    FUNCTION:

            OP_OP KW_DEF IDENTIFIER EXP OP_CP                        {  createFunction(1,$3,$4); $$ = $3;  }
        |   OP_OP KW_DEF IDENTIFIER IDENTIFIER EXP OP_CP             {  createFunction(0,$3,$5); $$ = $3;  }
        |   OP_OP KW_DEF IDENTIFIER IDENTIFIER IDENTIFIER EXP OP_CP  {  createFunction(0,$3,$6); $$ = $3;  }
        ;
/* 
   Daha sonra burada EXP'ın bir ıdentifier olmayacağı senaryo üstüne bir deneme yap 
   bu sayde fonksiyon tanımlandığında (+ a b) gibi bir ifadede a ve b ıdentifier olduğu için
   değerlendirilmeyecek ve fonksiyon tanımlanırken işlem yapılmayacak
*/
    EXP:
            /* Arithmetic */
            OP_OP OP_PLUS    EXP EXP OP_CP      {  $$ = "OP_PLUS";  if (type == 1) {evaluateOperator("OP_PLUS",  getVarContent($3), getVarContent($4));} } /* (+ var1 var2) */
        |   OP_OP OP_MINUS   EXP EXP OP_CP      {  $$ = "OP_MINUS"; if (type == 1) {evaluateOperator("OP_MINUS", getVarContent($3), getVarContent($4));} } /* (- var1 var2) */
        |   OP_OP OP_MULT    EXP EXP OP_CP      {  $$ = "OP_MULT";  if (type == 1) {evaluateOperator("OP_MULT",  getVarContent($3), getVarContent($4));} } /* (* var1 var2) */
        |   OP_OP OP_DIV     EXP EXP OP_CP      {  $$ = "OP_DIV";   if (type == 1) {evaluateOperator("OP_DIV",   getVarContent($3), getVarContent($4));} } /* (/ var1 var2) */
        |   OP_OP OP_MINUS   EXP     OP_CP      {  $$ = "OP_MINUS"; if (type == 1) {evaluateOperator("OP_MINUS", getVarContent($3), NULL);             } } /* (- var1)      */
            /* Boolean */
        |   OP_OP KW_NOT     EXP     OP_CP      {  $$ = processNot(getVarContent($3));                      }
        |   OP_OP KW_AND     EXP EXP OP_CP      {  $$ = processAnd(getVarContent($3),getVarContent($4));    }
        |   OP_OP KW_OR      EXP EXP OP_CP      {  $$ = processOr(getVarContent($3),getVarContent($4));     }
        |   OP_OP KW_EQUAL   EXP EXP OP_CP      {  $$ = isEqual(getVarContent($3),getVarContent($4));       }
        |   OP_OP KW_LESS    EXP EXP OP_CP      {  $$ = isLess(getVarContent($3),getVarContent($4));        }
        |   OP_OP KW_IF EXP EXP EXP OP_CP       {  if(strcmp($3,"true") == 0) { $$ = $4; } else { $$ = $5; } }
            /* Assignment */
        |   OP_OP KW_SET IDENTIFIER EXP OP_CP   {  setVar($3,$4);  $$ = $4; } /* (set a b) */
            /* Calling Functions*/
        |   OP_OP KW_DISP EXP OP_CP             {   /* (disp a) */
                                                    $<string>$ = getVarContent($3); 

                                                    if($$ != NULL && strcmp($$, "nil") != 0) 
                                                    { 
                                                        printf("%s\n",$$);
                                                    } 

                                                    else 
                                                    { 
                                                        fprintf(stderr, "Error: This is (%s) a nil variable (it is not printable)\n",$3); 
                                                        exit(EXIT_FAILURE); 
                                                    } 
                                                } 
        |   OP_OP IDENTIFIER OP_CP              {  $<string>$ = getFunctionValue(1,$2,NULL,NULL);                           } /* (func)     */
        |   OP_OP IDENTIFIER EXP OP_CP          {  $<string>$ = getFunctionValue(0,$2,getVarContent($3),NULL);              } /* (func a)   */
        |   OP_OP IDENTIFIER EXP EXP OP_CP      {  $<string>$ = getFunctionValue(0,$2,getVarContent($3),getVarContent($4)); } /* (func a b) */  
            /* Primitive */ 
        |   IDENTIFIER                          {  $$ = $1;   type = 0; } 
        |   VALUEF                              {  $$ = $1;   type = 1; }
        |   KW_FALSE                            {  $$ = "false";        }
        |   KW_TRUE                             {  $$ = "true";         }
        |   KW_NIL                              {  $$ = "nil";          }
        |   OP_PLUS                             {  $$ = "OP_PLUS";      }
        |   OP_MINUS                            {  $$ = "OP_MINUS";     }
        |   OP_MULT                             {  $$ = "OP_MULT";      }
        |   OP_DIV                              {  $$ = "OP_DIV";       }
        ;

%% /* CFG RULES END */

int main(int argc, char *argv[])
{
    if (argc == 1)
    {
        printf("Type (exit) for exit\n");
        printf(">\n");
    }

    else if (argc == 2)
    {
        yyin = fopen(argv[1], "r");

        if (yyin == NULL)
        {
            printf("File not found\n");
            return 0;
        }
    }

    else 
    {
        printf("Too many arguments\n");
        printf("Usage: ./gpp_interpreter or ./gpp_interpreter <filename>\n");
        return 0;
    }
    yyparse();
}