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

int comment_start_symbol = 0;
int string_start_symbol = 0;
bool in_nested_comment = false;
bool in_string = false;

%}

/*
 * Define names for regular expressions here.
 */

%x MULTIPLE_COMMENT
%x INLINE_COMMENT
%x STRING_CONSTANT

DARROW                      =>
LE                          <=
ASSIGN                      <-
MULTIPLE_COMMENT_START      "(*"
MULTIPLE_COMMENT_END        "*)"
INLINE_COMMENT_TOKEN        "--"
BLANK                       (" "|\f|\r|\t|\v)
OPERATOR                    ("+"|"-"|"*"|"/")
SINGLE_CHAR_TOKEN           ("~"|"<"|"="|"("|")"|"{"|"}"|";"|":"|"."|","|"@")
TYPEID                      [A-Z][a-zA-Z0-9_]*
OBJECTID                    [a-z][a-zA-Z0-9_]*
CLASS                       [Cc][Ll][Aa][Ss][Ss]
IN                          [Ii][Nn]  
ELSE                        [Ee][Ll][Ss][Ee]   
FI                          [Ff][Ii]          
IF                          [Ii][Ff]          
INHERITS                    [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] 
ISVOID                      [Ii][Ss][Vv][Oo][Ii][Dd]    
LOOP                        [Ll][Oo][Oo][Pp]   
POOL                        [Pp][Oo][Oo][Ll]   
THEN                        [Tt][Hh][Ee][Nn]   
WHILE                       [Ww][Hh][Ii][Ll][Ee]
LET                         [Ll][Ee][Tt]  
CASE                        [Cc][Aa][Ss][Ee]
ESAC                        [Ee][Ss][Aa][Cc]   
NEW                         [Nn][Ee][Ww]      
OF                          [Oo][Ff]          
NOT                         [Nn][Oo][Tt]      
BOOL_CONST_FALSE            f[Aa][Ll][Ss][Ee]
BOOL_CONST_TRUE             t[Rr][Uu][Ee]
INT_CONST                   [0-9]+

STRING_CONSTANT             "\"".*(\\\n.*)*.*"\""

%%

 /*
  *  Nested comments
  */

{MULTIPLE_COMMENT_START} {BEGIN(MULTIPLE_COMMENT); comment_start_symbol++; in_nested_comment=true;}

<MULTIPLE_COMMENT>\n        { curr_lineno++; }

<MULTIPLE_COMMENT>{MULTIPLE_COMMENT_START} { comment_start_symbol++;}

<MULTIPLE_COMMENT>{MULTIPLE_COMMENT_END} { // Para cada simbolo encontrado diminui 
  comment_start_symbol--;

  if (comment_start_symbol == 0) {
    in_nested_comment = false;
    BEGIN(INITIAL);
  }

  if(comment_start_symbol < 0){
    cool_yylval.error_msg = "final de comentario inesperado!";
	  return (ERROR);
  }
}

<MULTIPLE_COMMENT><<EOF>> {
  BEGIN(INITIAL);
  cool_yylval.error_msg = "syntax error at or near ERROR = EOF in comment";
	return (ERROR);
}

<MULTIPLE_COMMENT>. {}

{MULTIPLE_COMMENT_END} {
  if(!in_nested_comment)
  {
    cool_yylval.error_msg = "final de comentario inesperado!";
	  return (ERROR);
  }
}

 /*
  *  inline comment
  */

{INLINE_COMMENT_TOKEN} {BEGIN(INLINE_COMMENT);}
<INLINE_COMMENT>.      {}
<INLINE_COMMENT>\n     { curr_lineno++; BEGIN(INITIAL); }

 /*
  *  The multiple-character operators.
  */              

{CLASS}             { return CLASS;}
{IN}                { return IN; }
{DARROW}            { return DARROW; }
{BLANK}             { /* ignore */ }
{SINGLE_CHAR_TOKEN} { return yytext[0]; }
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

{STRING_CONSTANT}   { return STR_CONST; }


\\n                 { printf("\n"); }
\\t                 { printf("\t"); }
\\b                 { printf("\b"); }
\\f                 { printf("\f"); }

\n	 { curr_lineno++; }

{INT_CONST}    {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (INT_CONST);
}     

{TYPEID} { 
  yylval.symbol = inttable.add_string(yytext); return (TYPEID); 
}

{OBJECTID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (OBJECTID);
}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{BOOL_CONST_FALSE}  { return (BOOL_CONST); }
{BOOL_CONST_TRUE}  { return (BOOL_CONST); }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

%%
