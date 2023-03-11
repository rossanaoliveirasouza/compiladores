/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

BLANK                                               " "|\f|\r|\t|\v

BITWISE_OPERATORS                                   "~"
COMPARISON_OPERATORS                                "<"|"="|">"
ARITHMETIC_OPERATORS                                "+"|"-"|"/"|"*"

TYPE_DECLARATION_OPERATOR                           ":"
END_OF_STATEMENT_OPERATOR                           ";"

SCOPE_DELIMITERS                                    "("|")"|"{"|"}"

INTEGER_CONSTANT                                    [-+]?[0-9]+

LETTER_ESCAPE                                       \a|\b|\c|\d|\e|\g|\h|\i|\j|\k|\l|\m|\o|\p|\q|\u|\v|\w|\x|\y|\z
STRING_CONSTANT                                     ".*({LETTER_ESCAPE})*(\\\n.*)*.*"

IDENTIFIER                                          [a-z_][a-zA-Z0-9_]*
INT_TYPE                                            [Ii][Nn][Tt]
BOOL_TYPE                                           [Bb][Oo][Oo][Ll]
OBJECT_TYPE                                         [Oo][Bb][Jj][Ee][Cc][Tt]
STRING_TYPE                                         [Ss][Tt][Rr][Ii][Nn][Gg]
SELF_TYPE                                           SELF_TYPE
TYPE_ID                                             {INT_TYPE}|{BOOL_TYPE}|{OBJECT_TYPE}|{STRING_TYPE}|{SELF_TYPE}

SELF_KEYWORD                                        self

SINGLE_CHAR_TOKEN                                   ("."|","|"@")
CLASS                                               [Cc][Ll][Aa][Ss][Ss]
IN                                                  [Ii][Nn]  
ELSE                                                [Ee][Ll][Ss][Ee]   
FI                                                  [Ff][Ii]          
IF                                                  [Ii][Ff]          
INHERITS                                            [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] 
ISVOID                                              [Ii][Ss][Vv][Oo][Ii][Dd]    
LOOP                                                [Ll][Oo][Oo][Pp]   
POOL                                                [Pp][Oo][Oo][Ll]   
THEN                                                [Tt][Hh][Ee][Nn]   
WHILE                                               [Ww][Hh][Ii][Ll][Ee]
LET                                                 [Ll][Ee][Tt]  
CASE                                                [Cc][Aa][Ss][Ee]
ESAC                                                [Ee][Ss][Aa][Cc]   
NEW                                                 [Nn][Ee][Ww]      
OF                                                  [Oo][Ff]          
NOT                                                 [Nn][Oo][Tt]      

BOOL_CONST                                          ([Ff]alse|[Tt]rue)

DARROW                                              =>

%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */
                    

{BLANK}             { /* ignore */ }

{CLASS}             { return CLASS; }
{IN}                { return IN; }
{DARROW}            { return DARROW; }
{IN}                { return IN; }
{ELSE}              { return ELSE; }
{FI}                { return FI; }
{IF}                { return IF; }
{INHERITS}          { return INHERITS; }
{ISVOID}            { return ISVOID; }
{LET}               { return LET; }
{LOOP}              { return LOOP; }
{POOL}              { return POOL; }
{THEN}              { return THEN; }
{WHILE}             { return WHILE; }
{CASE}              { return CASE; }
{ESAC}              { return ESAC; }
{NEW}               { return NEW; }
{OF}                { return OF; }
{NOT}               { return NOT; }

{LETTER_ESCAPE}     { printf("escape"); }

{BOOL_CONST}        { return BOOL_CONST; }
{STRING_CONSTANT}   { return STR_CONST; }
{INTEGER_CONSTANT}  { return INT_CONST; }

{TYPE_ID}           { return TYPEID; }
{IDENTIFIER}        { return OBJECTID; }


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
