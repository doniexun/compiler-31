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

#define LOGGING true

#define QUOTE(name) #name
#define LOG(log_string) if(LOGGING){printf("\t\t\t%s\n", QUOTE(log_string));}

%}
%x comment

/*
 * Define names for regular expressions here.
 */

WHITE_SPACE		[\n\t\b\f ]

OPEN_COMMENT		"(*"
CLOSE_COMMENT		"*)"

STRING 			\"(\\.|[^"])*\"
CHARACTER		\'(\\.|[^'])\'

OPEN_PAREN		"("
CLOSE_PAREN		")"
OPEN_BRACE		"{"
CLOSE_BRACE		"}"
OPEN_SBRACE		"["
CLOSE_SBRACE		"]"

COMMA			","

DARROW			"=>"
ASSIGNMENT		"<-"

/* operators */
PLUS 			"+"
MINUS 			"-"
DIV			"/"
MUL			"*"
LT			"<"
GT			">"
DOT			"."
EQUAL			"="

SEMI_COLON		";"
COLON			":"

KEYWORDS 		class|inherits|self|if|then|else|fi|let|end|while|loop|pool|new|SELF_TYPE|Int|String

DIGIT			[0-9]
INTEGER			{DIGIT}+

ID			[a-zA-Z_][a-zA-Z0-9_]*

%%

 /*
  *  Nested comments
  */

{OPEN_COMMENT} BEGIN(comment);

<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*)\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             /* line number increment */
<comment>{CLOSE_COMMENT} BEGIN(INITIAL);

 /* strings */
{STRING} ECHO; LOG(STRING);

 /* characters */
{CHARACTER} ECHO; LOG(CHARACTER);

{INTEGER} ECHO; LOG(INTEGER);

 /* terminals */
{OPEN_PAREN} ECHO; LOG(OPEN_PAREN);
{CLOSE_PAREN} ECHO; LOG(CLOSE_PAREN);
{OPEN_BRACE} ECHO; LOG(OPEN_BRACE);
{CLOSE_BRACE} ECHO; LOG(CLOSE_BRACE);
{OPEN_SBRACE} ECHO; LOG(OPEN_SBRACE);
{CLOSE_SBRACE} ECHO; LOG(CLOSE_SBRACE);
{SEMI_COLON} ECHO; LOG(SEMI_COLON);
{COLON} ECHO; LOG(COLON);
{COMMA} ECHO; LOG(COMMA);


 /*
  *  The multiple-character operators.
  */
{DARROW}	{ 
	ECHO; LOG(DARROW);
	return (DARROW); 
}

{ASSIGNMENT} ECHO; LOG(ASSIGNMENT);

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

 /* 
  * operators 
  */
{PLUS}|{MINUS}|{DIV}|{MUL}|{LT}|{GT}|{DOT}|{EQUAL} ECHO; LOG(OPERATOR);

 /* 
  * keywords 
  */
{KEYWORDS} ECHO; LOG(KEYWORD);

{ID} ECHO; LOG(ID);

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
{WHITE_SPACE} /* ignore */

%%

/*
cool_yylex  returns integer code 
cool_yylval  data structure 
cool_yylval.symbol  saving symbols 
cool_yylval.boolean  saving semantic value 
*/
