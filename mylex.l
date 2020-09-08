/* Lytridis Nikiolaos | AM: 2009030088 */
/* Spiros Agrimakis   |	AM: 2008030037 */
%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "myanalyzer.tab.h"
#include "cgen.h"


int line_number = 1;
/* 
	A primitive macro facility:
	just one macro is allowed to be defined! 
*/
#define MAXMACRO 32
char* mactable[MAXMACRO][2];
int mactable_size = 0;

/* Return 1 on success, 0 on failure (macro table full) */
int set_macro(char* name, char* def);

/* Return def for macro, or NULL if no such macro is defined. */
char* get_macro(char* name);

%}

%x comm
%x macro

number     ([0-9]+\.?|[0-9]*\.[0-9]+)
identifier [A-Za-z][A-Za-z0-9_]*


digit		[0-9]

exp			[Ee][\+\-]?{digit}{1,3}
sign        [\+\-]
dot 		[\.]
white 		[ \t\r]*
nl			[\n]
backslash	[\\]
quote		[\']
dblquotes	[\"]

falseEndKeyword		[;][Ee][Nn][Dd]


andKeyword		[Aa][Nn][Dd]
arrayKeyword		[Aa][Rr][Rr][Aa][Yy]
booleanKeyword		[Bb][Oo][Oo][Ll][Ee][Aa][Nn]
charKeyword		[Cc][Hh][Aa][Rr]
beginKeyword		[Bb][Ee][Gg][Ii][Nn]
divKeyword		[Dd][Ii][Vv]
doKeyword		[Dd][Oo]
elseKeyword		[Ee][Ll][Ss][Ee]
forKeyword		[Ff][Oo][Rr]
endKeyword		[Ee][Nn][Dd]
functionKeyword		[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]
gotoKeyword		[Gg][Oo][Tt][Oo]
ifKeyword		[Ii][Ff]
integerKeyword		[Ii][Nn][Tt][Ee][Gg][Ee][Rr]
varKeyword		[Vv][Aa][Rr]
modKeyword		[Mm][Oo][Dd]
notKeyword		[Nn][Oo][Tt]
ofKeyword		[Oo][Ff]
orKeyword		[Oo][Rr]
whileKeyword		[Ww][Hh][Ii][Ll][Ee]
procedureKeyword	[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]
programKeyword		[Pp][Rr][Oo][Gg][Rr][Aa][Mm]
realKeyword		[Rr][Ee][Aa][Ll]
repeatKeyword		[Rr][Ee][Pp][Ee][Aa][Tt]
toKeyword		[Tt][Oo]
resultKeyword		[Rr][Ee][Ss][Uu][Ll][Tt]
returnKeyword		[Rr][Ee][Tt][Uu][Rr][Nn]
thenKeyword		[Tt][Hh][Ee][Nn]
untilKeyword		[Uu][Nn][Tt][Ii][Ll]
downtoKeyword		[Dd][Oo][Ww][Nn][Tt][Oo]
typeKeyword		[Tt][Yy][Pp][Ee]

readStringKW		[Rr][Ee][Aa][Dd][Ss][Tt][Rr][Ii][Nn][Gg]
readIntegerKW		[Rr][Ee][Aa][Dd][Ii][Nn][Tt][Ee][Gg][Ee][Rr]
readRealKW		[Rr][Ee][Aa][Dd][Rr][Ee][Aa][Ll]
writeStringKW		[Ww][Rr][Ii][Tt][Ee][Ss][Tt][Rr][Ii][Nn][Gg]
writeIntegerKW		[Ww][Rr][Ii][Tt][Ee][Ii][Nn][Tt][Ee][Gg][Ee][Rr]
writeRealKW		[Ww][Rr][Ii][Tt][Ee][Rr][Ee][Aa][Ll]



trueKeyword		[Tt][Rr][Uu][Ee]
falseKeyword		[Ff][Aa][Ll][Ss][Ee]


defineKeyWord		[#][Dd][Ee][Ff][Ii][Nn][Ee]

integerConst		(0|[1-9][0-9]*)
realConst			(({digit}+{dot}{digit}*{exp}?)|({digit}*{dot}{digit}+{exp}?))
booleanConst 		{trueKeyword}|{falseKeyword}

dataType			{integerKeyword}|{booleanKeyword}|{charKeyword}|{realKeyword}
casting				[(]{dataType}[)]

character 			([^'"\\]|"\\n"|"\\t"|"\\r"|"\\\\"|"\\\'"|"\\\"")+
characters		 	{character}*
string 				[\"]{characters}*[\"]|[\']{characters}*[\']
one_char 			[\']{character}[\']

Comments 			[(][*]{characters}*[*][)]
LineComment 		[#][^\n]* 




%%

@defmacro[ \r\t]+       BEGIN(macro);
<macro>{identifier}             {
							/* Store macro name */
							char* name = strdup(yytext);
							char* def = NULL;
							size_t deflen = 0;
							char c;
								
							FILE* deff = open_memstream(&def, &deflen);

							while((c=input())!='\n')
							   fputc(c, deff);
							fclose(deff);

							if(!set_macro(name, def))
								printf("lexer error: failed to define macro '%s'\n", name);
							BEGIN(INITIAL);
						};

{readStringKW}			{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return READSTRING_TK; }
{readIntegerKW}			{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return READINT_TK; }
{readRealKW}			{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return READREAL_TK; }
{writeStringKW}			{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return WRITESTRING_TK; }
{writeIntegerKW}		{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return WRITEINT_TK; }
{writeRealKW}			{printf("<Special Identifier: %s>", yylval.crepr = strdup(yytext)); return WRITEREAL_TK; }


{falseEndKeyword}			{printf("<Unecpected SemiColon Token before END: %s>", yylval.crepr = strdup(yylval.crepr = strdup(yytext))); return AND_TK; }

{andKeyword}			{printf("<Keyword and: %s>", yylval.crepr = strdup(yytext)); return AND_TK; }
{arrayKeyword}			{printf("<Keyword array: %s>", yylval.crepr = strdup(yytext)); return ARRAY_TK; }
{booleanKeyword}		{printf("<Keyword boolean: %s>", yylval.crepr = strdup(yytext)); return BOOLEAN_TK; }
{charKeyword}			{printf("<Keyword char: %s>", yylval.crepr = strdup(yytext)); return CHAR_TK; }
{beginKeyword}			{printf("<Keyword begin: %s>", yylval.crepr = strdup(yytext)); return BEGIN_TK; }
{divKeyword}			{printf("<Keyword div: %s>", yylval.crepr = strdup(yytext)); return DIV_TK; }
{doKeyword}			{printf("<Keyword do: %s>", yylval.crepr = strdup(yytext)); return DO_TK; }
{elseKeyword}			{printf("<Keyword else: %s>", yylval.crepr = strdup(yytext)); return ELSE_TK; }
{forKeyword}			{printf("<Keyword for: %s>", yylval.crepr = strdup(yytext)); return FOR_TK; }
{endKeyword}			{printf("<Keyword end: %s>", yylval.crepr = strdup(yytext)); return END_TK; }
{functionKeyword}		{printf("<Keyword function: %s>", yylval.crepr = strdup(yytext)); return FUNCTION_TK; }
{gotoKeyword}			{printf("<Keyword goto: %s>", yylval.crepr = strdup(yytext)); return GOTO_TK; }
{ifKeyword}			{printf("<Keyword if: %s>", yylval.crepr = strdup(yytext)); return IF_TK; }
{integerKeyword}		{printf("<Keyword integer: %s>", yylval.crepr = strdup(yytext)); return INTEGER_TK; }
{varKeyword}			{printf("<Keyword var: %s>", yylval.crepr = strdup(yytext)); return VAR_TK; }
{modKeyword}			{printf("<Keyword mod: %s>", yylval.crepr = strdup(yytext)); return MOD_TK; }
{notKeyword}			{printf("<Keyword not: %s>", yylval.crepr = strdup(yytext)); return NOT_TK; }
{ofKeyword}			{printf("<Keyword of: %s>", yylval.crepr = strdup(yytext)); return OF_TK; }
{orKeyword}			{printf("<Keyword or: %s>", yylval.crepr = strdup(yytext)); return OR_TK; }
{whileKeyword}			{printf("<Keyword while: %s>", yylval.crepr = strdup(yytext)); return WHILE_TK; }
{procedureKeyword}		{printf("<Keyword procedure: %s>", yylval.crepr = strdup(yytext)); return PROCEDURE_TK; }
{programKeyword}		{printf("<Keyword program: %s>", yylval.crepr = strdup(yytext)); return PROGRAM_TK; }
{realKeyword}			{printf("<Keyword real: %s>", yylval.crepr = strdup(yytext)); return REAL_TK; }
{repeatKeyword}			{printf("<Keyword repeat: %s>", yylval.crepr = strdup(yytext)); return REPEAT_TK; }
{toKeyword}			{printf("<Keyword to: %s>", yylval.crepr = strdup(yytext)); return TO_TK; }
{resultKeyword}			{printf("<Keyword result: %s>", yylval.crepr = strdup(yytext)); return RESULT_TK; }
{returnKeyword}			{printf("<Keyword return: %s>", yylval.crepr = strdup(yytext)); return RETURN_TK; }
{thenKeyword}			{printf("<Keyword then: %s>", yylval.crepr = strdup(yytext)); return THEN_TK; }
{untilKeyword}			{printf("<Keyword until: %s>", yylval.crepr = strdup(yytext)); return UNTIL_TK; }	
{downtoKeyword}			{printf("<Keyword downto: %s>", yylval.crepr = strdup(yytext)); return DOWNTO_TK; }
{typeKeyword}			{printf("<Keyword Type: %s>", yylval.crepr = strdup(yytext)); return TYPE_TK; }

{booleanConst}			{printf("<Keyword boolean: %s>", yylval.crepr = strdup(yytext)); return BOOL_CONST_TK; }

{defineKeyWord}			{printf("<Define KeyWord: %s>", yylval.crepr = strdup(yytext)); return DEFINE_TK; }

{identifier}			{printf("<Identifier: %s>", yylval.crepr = strdup(yytext)); return IDENTIFIER_TK; }
{integerConst}			{printf("<Integer positive Constant :%s>", yylval.crepr = strdup(yytext)); return INT_CONST_TK; }
{realConst}			{printf("<Real positive Constant :%s>", yylval.crepr = strdup(yytext)); return REAL_CONST_TK; }

{casting}			{printf("<Casting: %s>", yylval.crepr = strdup(yytext)); return CASTING_TK; }

{one_char}			{printf("<Constant Char: %s>", yylval.crepr = strdup(yytext)); return ONE_CHAR_TK; }

{string}			{printf("<Constant String: %s>", yylval.crepr = strdup(yytext)); return STRING_TK; }

{number}			{printf("<Found the number: %s>", yylval.crepr = strdup(yytext)); return NUMBER_TK; }
{nl}       			{printf("\n"); line_number += 1;}

{white}       			{printf(" "); }


"(*"                 BEGIN(comm);
<comm>[^)*\n]+
<comm>\n            ++line_number;
<comm><<EOF>>    yyerror("EOF in comment");
<comm>"*)"       BEGIN(INITIAL);
<comm>[*)]

":="			{printf("<Entrastment: %s>", yylval.crepr = strdup(yytext)); return ENTRASMENT_TK; }

"."				{printf("<Dot: %s>", yylval.crepr = strdup(yytext)); return DOT_TK; }
";"				{printf("<SemiColon: %s>", yylval.crepr = strdup(yytext)); return SEMICOLON_TK; }
"("   			{printf("<Left Bracket: %s>", yylval.crepr = strdup(yytext)); return LEFT_BRACHET_TK; }
")"				{printf("<Right Bracket: %s>", yylval.crepr = strdup(yytext)); return RIGHT_BRACHET_TK; }
"{"   			{printf("<Left Braces: %s>", yylval.crepr = strdup(yytext)); return LEFT_BRACHES_TK; }
"}"   			{printf("<Right Braces: %s>", yylval.crepr = strdup(yytext)); return RIGHT_BRACHES_TK; }
":"				{printf("<Colon: %s>", yylval.crepr = strdup(yytext)); return COLON_TK; }
","				{printf("<Comma: %s>", yylval.crepr = strdup(yytext)); return COMMA_TK; }
"["				{printf("<Left Back: %s>", yylval.crepr = strdup(yytext)); return LEFT_BACK_TK; }
"]"				{printf("<Right Back: %s>", yylval.crepr = strdup(yytext)); return RIGHT_BACK_TK; }

"+"				{printf("<Plus: %s>", yylval.crepr = strdup(yytext)); return PLUS_TK; }
"-"				{printf("<Minus: %s>", yylval.crepr = strdup(yytext)); return MINUS_TK; }
"*"				{printf("<Asterisc operator: %s>", yylval.crepr = strdup(yytext)); return ASTERISC_TK; }
"/"				{printf("<Divide operator: %s>", yylval.crepr = strdup(yytext)); return DIVIDE_TK; }

"="				{printf("<Equals operator: %s>", yylval.crepr = strdup(yytext)); return EQUALS_TK; }
">="			{printf("<Beq operator: %s>", yylval.crepr = strdup(yytext)); return BEG_TK; }
"<="			{printf("<Leq operator: %s>", yylval.crepr = strdup(yytext)); return LEQ_TK; }
">"				{printf("<Bigger operator: %s>", yylval.crepr = strdup(yytext)); return BIGGER_TK; }
"<"				{printf("<Less operator: %s>", yylval.crepr = strdup(yytext)); return LESS_TK; }
"<>"			{printf("<Unequal operator: %s>", yylval.crepr = strdup(yytext)); return UNEQUAL_TK; }

"&&"			{printf("<And operator: %s>", yylval.crepr = strdup(yytext)); return ANDD_TK; }
"||"			{printf("<Or operator: %s>", yylval.crepr = strdup(yytext)); return ORR_TK; }
"!"				{printf("<Exclamation: %s>", yylval.crepr = strdup(yytext)); return EXCLAMATION_TK; }

"\\"			{printf("<BackSlash operator: %s>", yylval.crepr = strdup(yytext)); return BACK_SLASH_TK; }



<<EOF>>	return EOF;
.                {printf("<Unrecognised Char>\n"); return 0;} //;

%%
int set_macro(char* name, char* def)
{
	/* Check to see if macro already defined, and redefine it. */
	int i;
	for(i=0; i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0) {
			/* found ! */
			free(name);
			free(mactable[i][1]);
			mactable[i][1] = def;
			break;
		}
	}
	if(i<mactable_size)
		return 1;
	else if(mactable_size < MAXMACRO) {
		/* new entry */
		assert(i==mactable_size);
		mactable[i][0] = name;
		mactable[i][1] = def;
		mactable_size++;
		return 1;
	}
	else
		return 0;
}

char* get_macro(char* name)
{	
	int i;
	for( i=0;i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0)
			return mactable[i][1];
	}
	return NULL;
}
