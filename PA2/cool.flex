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

#define MAXIMUM_LENGTH_OF_STRING_CONSTANT 256

bool escape_line_break_was_used = false;

char stringConstant[MAXIMUM_LENGTH_OF_STRING_CONSTANT];
int stringConstantNextCharIndex = 0;

void resetStringConstant() {
  memset(stringConstant, '\0', MAXIMUM_LENGTH_OF_STRING_CONSTANT);
  stringConstantNextCharIndex = 0;
}

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
ARITHMETIC_OPERATORS        ("+"|"-"|"*"|"/")
SINGLE_CHAR_TOKEN           ("~"|"<"|"="|"("|")"|"{"|"}"|";"|":"|"."|","|"@")
BOOL_CONST_FALSE            f[Aa][Ll][Ss][Ee]
BOOL_CONST_TRUE             t[Rr][Uu][Ee]
INT_CONST                   [0-9]+
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

TYPEID                      ("SELF_TYPE"|[A-Z]([a-zA-Z0-9_])*)
OBJECTID                    ("self"|[a-z]([a-zA-Z0-9_])*)


%%

 /*
  *  Nested comments
  */

{MULTIPLE_COMMENT_START} {BEGIN(MULTIPLE_COMMENT); comment_start_symbol++; in_nested_comment=true;}

<MULTIPLE_COMMENT>\n  { curr_lineno++; } // For each line found increases the value of curr_lineno

<MULTIPLE_COMMENT>{MULTIPLE_COMMENT_START} { comment_start_symbol++;}

<MULTIPLE_COMMENT>{MULTIPLE_COMMENT_END} { // For each symbol found decreases the value of comment_start_symbol
  comment_start_symbol--;

  if (comment_start_symbol == 0) {
    in_nested_comment = false;
    BEGIN(INITIAL);
  }

  if(comment_start_symbol < 0){
    cool_yylval.error_msg = "END OF COMMENT symbol found unexpectedly!";
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
    cool_yylval.error_msg = "END OF COMMENT symbol found unexpectedly!";
	  return (ERROR);
  }
}

 /*
  *  inline comment
  */

{INLINE_COMMENT_TOKEN} {BEGIN(INLINE_COMMENT);}
<INLINE_COMMENT>.      {}
<INLINE_COMMENT>\n     { curr_lineno++; BEGIN(INITIAL); } // Also increases the value of curr_lineno for each single line comment found



 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
  BEGIN(STRING_CONSTANT);

  resetStringConstant();
}

<STRING_CONSTANT>\" {
  BEGIN(INITIAL);
  
  stringConstant[stringConstantNextCharIndex] = '\0';
  cool_yylval.symbol = stringtable.add_string(stringConstant);

  resetStringConstant();

  return STR_CONST;
}

<STRING_CONSTANT><EOF> {
  cool_yylval.error_msg = "EOF in string constant";

  resetStringConstant();

  return (ERROR);
}
 
<STRING_CONSTANT>\n {
  curr_lineno++;

  cool_yylval.error_msg = "Unterminated string constant";

  resetStringConstant();

  return (ERROR);
}

<STRING_CONSTANT>\0 {
  cool_yylval.error_msg = "String contains null character";

  resetStringConstant();

  return (ERROR);
}

<STRING_CONSTANT>(\\n|\\\n) {
  curr_lineno++;
  stringConstant[stringConstantNextCharIndex++] = '\n';
}

<STRING_CONSTANT>\\t {
  stringConstant[stringConstantNextCharIndex++] = '\t';
}

<STRING_CONSTANT>\\f {
  stringConstant[stringConstantNextCharIndex++] = '\f';
}

<STRING_CONSTANT>\\b {
  stringConstant[stringConstantNextCharIndex++] = '\b';
}

<STRING_CONSTANT>\\.{} { // Treat generic Escape as different from null
    if (stringConstantNextCharIndex + 1 < MAXIMUM_LENGTH_OF_STRING_CONSTANT) {
      stringConstant[stringConstantNextCharIndex] = yytext[1]; 
    } 
    else {
      cool_yylval.error_msg = "String constant too long";
      resetStringConstant();
      return (ERROR); 
    }
}

<STRING_CONSTANT>. {
  if (stringConstantNextCharIndex >= MAXIMUM_LENGTH_OF_STRING_CONSTANT) {
    cool_yylval.error_msg = "String constant too long";

    resetStringConstant();

    return ERROR;
  }

  stringConstant[stringConstantNextCharIndex++] = yytext[0];
}

 /*
  *  The multiple-character operators.
  */              

{BLANK}                     { /* ignore */ }

{ASSIGN}	                  { return ASSIGN;}
{CLASS}                     { return CLASS;}
{IN}                        { return IN; }
{DARROW}                    { return DARROW; }
{ARITHMETIC_OPERATORS}      { return (int)yytext[0]; }
{SINGLE_CHAR_TOKEN}         { return (int)yytext[0]; }
{IN}                        { return IN; }
{ELSE}                      { return ELSE; }
{FI}                        { return FI; }
{IF}                        { return IF; }
{INHERITS}                  { return INHERITS; }
{ISVOID}                    { return ISVOID; }
{LET}                       { return LET; }
{LOOP}                      { return LOOP; }
{POOL}                      { return POOL; }
{THEN}                      { return THEN; }
{WHILE}                     { return WHILE; }
{CASE}                      { return CASE; }
{ESAC}                      { return ESAC; }
{NEW}                       { return NEW; }
{OF}                        { return OF; }
{NOT}                       { return NOT; }
{LE}                        { return LE; }


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


{BOOL_CONST_FALSE}  { 
	cool_yylval.boolean = false;
  return (BOOL_CONST); }

{BOOL_CONST_TRUE}  { 
  cool_yylval.boolean = true;
  return (BOOL_CONST); 
}


\n { 
  curr_lineno++;
}

{INT_CONST}    {
  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST);
}    

{TYPEID} { 
  yylval.symbol = idtable.add_string(yytext);
  return (TYPEID); 
}

{OBJECTID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (OBJECTID);
}

. {
  cool_yylval.error_msg = yytext;
  return (ERROR);
}





%%
