/* Lytridis Nikiolaos | AM: 2009030088 */
/* Spiros Agrimakis   |	AM: 2008030037 */
%{
	#include <stdio.h>
	#include <stdarg.h>
	#include <string.h>
	#include "cgen.h"
	
	extern int line_number;
	//void yyerror(char *message);
	int array_n =1;

%}

%union
{
	char* crepr;
}

%debug
%token ARRAY_TK
%token BOOLEAN_TK
%token CHAR_TK
%token BEGIN_TK
%token DO_TK
%nonassoc ELSE_TK
%token FOR_TK
%token END_TK
%token FUNCTION_TK
%token GOTO_TK
%token IF_TK
%token INTEGER_TK
%token VAR_TK
%token OF_TK
%token WHILE_TK
%token PROCEDURE_TK
%token PROGRAM_TK
%token REAL_TK
%token REPEAT_TK
%token TO_TK
%token <crepr> RESULT_TK
%token RETURN_TK
%nonassoc THEN_TK
%token UNTIL_TK
%token DOWNTO_TK
%token <crepr> BOOL_CONST_TK
%token DEFINE_TK
%token <crepr> IDENTIFIER_TK
%token <crepr> INT_CONST_TK
%token <crepr> REAL_CONST_TK
%token <crepr> ONE_CHAR_TK
%token <crepr> STRING_TK
%token <crepr> NUMBER_TK
%token NL_TK
%token WHITE_TK
%token <crepr> COMMENTS_TK
%token <crepr> LINE_COMMENT_TK
%token DOT_TK
%token SEMICOLON_TK
%token LEFT_BRACHET_TK
%token RIGHT_BRACHET_TK
%token LEFT_BRACHES_TK
%token RIGHT_BRACHES_TK
%token COLON_TK
%token COMMA_TK
%token LEFT_BACK_TK
%token RIGHT_BACK_TK
%token TYPE_TK

%token <crepr> READSTRING_TK
%token <crepr> READINT_TK
%token <crepr> READREAL_TK
%token <crepr> WRITESTRING_TK
%token <crepr> WRITEINT_TK
%token <crepr> WRITEREAL_TK



%token BACK_SLASH_TK
%token ENTRASMENT_TK
	
%right  NOT_TK EXCLAMATION_TK
%right  SIGN_TK
%right <crepr> CASTING_TK
%left	MOD_TK DIV_TK ASTERISC_TK DIVIDE_TK
%left 	PLUS_TK MINUS_TK
%left 	EQUALS_TK BEG_TK LEQ_TK BIGGER_TK LESS_TK UNEQUAL_TK
%left 	ANDD_TK AND_TK
%left 	ORR_TK OR_TK

%start main_struct

%type <crepr> main_struct matrix types0 types types2
%type <crepr> expression3 exp identifier1 variables_declaration variables_declaration0
%type <crepr> subprograms subprograms_declaration parameters
%type <crepr> main_code body0 body body1 body_assignment s
%type <crepr> body_if else_pt body_for body_while body_goto 
%type <crepr> body_return body_label body_sub
%type <crepr> exp1 data_type

%%

main_struct: PROGRAM_TK IDENTIFIER_TK SEMICOLON_TK
		types
		variables_declaration0
		subprograms
		main_code DOT_TK
		{ 		
				printf("\n\n/*********************** C ***********************/\n\n");
				puts(c_prologue);
				printf("/* Program  %s */ \n\n", $2);
				printf("%s\n%s\n%s\nint main()\n{\n%s\n}", $4,$5,$6,$7);
				
			
		}
		;

matrix:	LEFT_BACK_TK expression3 RIGHT_BACK_TK				{ $$ = template("[%s]", $2); }
		|matrix LEFT_BACK_TK expression3 RIGHT_BACK_TK		{ $$ = template("%s[%s]",$1, $3); }
		;		

types:	/*empty*/							{ $$ = ""; }
		|TYPE_TK types0						{ $$ = $2; }
		;

types0:	IDENTIFIER_TK EQUALS_TK data_type SEMICOLON_TK types2		{ $$ = template("typedef %s %s;\n%s", $3,$1,$5); }
		;
types2:	/*empty*/							{ $$ = ""; }
		|IDENTIFIER_TK EQUALS_TK data_type SEMICOLON_TK types2 	{ $$ = template("typedef %s %s;\n%s", $3,$1,$5); }
		;


expression3: IDENTIFIER_TK  							{}
		|BOOL_CONST_TK							{}
		|REAL_CONST_TK							{}
		|INT_CONST_TK							{}
		|ONE_CHAR_TK							{ $$ = string_ptuc2c($1); }
		|STRING_TK							{ $$ = string_ptuc2c($1); }

		|READSTRING_TK LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("gets"); }
		|READINT_TK	LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("atoi(gets())"); }
		|READREAL_TK	LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("atof(gets())"); }
		|WRITESTRING_TK LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("puts"); }
		|WRITEINT_TK	LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("printf"); }
		|WRITEREAL_TK	LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("printf"); }

		|READSTRING_TK LEFT_BRACHET_TK  RIGHT_BRACHET_TK		{ $$ = template("gets()"); }
		|READINT_TK	LEFT_BRACHET_TK  RIGHT_BRACHET_TK	{ $$ = template("atoi(gets())"); }
		|READREAL_TK	LEFT_BRACHET_TK  RIGHT_BRACHET_TK	{ $$ = template("atof(gets())"); }
		|WRITESTRING_TK LEFT_BRACHET_TK  RIGHT_BRACHET_TK	{ $$ = template("puts()"); }
		|WRITEINT_TK	LEFT_BRACHET_TK  RIGHT_BRACHET_TK	{ $$ = template("printf"); }
		|WRITEREAL_TK	LEFT_BRACHET_TK  RIGHT_BRACHET_TK	{ $$ = template("printf"); }

		|IDENTIFIER_TK matrix					{ $$ = template("%s%s", $1,$2); }

		|LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK		{ $$ = template("(%s)", $2); }

		|IDENTIFIER_TK LEFT_BRACHET_TK expression3 RIGHT_BRACHET_TK	{ $$ = template("%s(%s)", $1, $3); }
		|IDENTIFIER_TK LEFT_BRACHET_TK  RIGHT_BRACHET_TK		{ $$ = template("%s()", $1); }

		|NOT_TK expression3						{ $$ = template("not%s", $2); }
		|EXCLAMATION_TK expression3					{ $$ = template("!%s", $2); }

		|PLUS_TK expression3						{ $$ = template("+%s", $2); }
		|MINUS_TK expression3						{ $$ = template("-%s", $2); }
		|CASTING_TK expression3						{ $$ = template("%s%s", $1, $2); }

		|expression3 ASTERISC_TK expression3				{ $$ = template("%s*%s", $1,$3); }
		|expression3 DIVIDE_TK expression3				{ $$ = template("%s/%s", $1,$3); }
		|expression3 DIV_TK expression3					{ $$ = template("%s div %s", $1,$3); }
		|expression3 MOD_TK expression3					{ $$ = template("%s mod %s", $1,$3); }

		|expression3 PLUS_TK expression3				{ $$ = template("%s+%s", $1,$3); }
		|expression3 MINUS_TK expression3				{ $$ = template("%s-%s", $1,$3); }

		|expression3 EQUALS_TK expression3				{ $$ = template("%s=%s", $1,$3); }
		|expression3 BEG_TK expression3					{ $$ = template("%s>=%s", $1,$3); }
		|expression3 LEQ_TK expression3					{ $$ = template("%s<=%s", $1,$3); }
		|expression3 BIGGER_TK expression3				{ $$ = template("%s>%s", $1,$3); }
		|expression3 LESS_TK expression3				{ $$ = template("%s<%s", $1,$3); }
		|expression3 UNEQUAL_TK expression3				{ $$ = template("%s!=%s", $1,$3); }

		|expression3 AND_TK expression3					{ $$ = template("%s and %s", $1,$3); }
		|expression3 ANDD_TK expression3				{ $$ = template("%s && %s", $1,$3); }
		|expression3 OR_TK expression3					{ $$ = template("%s or %s", $1,$3); }	
		|expression3 ORR_TK expression3					{ $$ = template("%s || %s", $1,$3); }
		;		

exp:										{ $$ = ""; }
		|IDENTIFIER_TK COLON_TK IDENTIFIER_TK				{ $$ = template("%s %s", $3, $1); }
		|IDENTIFIER_TK COLON_TK data_type				{ $$ = template("%s %s", $3, $1); }
		|exp COMMA_TK IDENTIFIER_TK COLON_TK IDENTIFIER_TK		{ $$ = template("%s, %s %s", $1, $5, $3); }
		|exp COMMA_TK IDENTIFIER_TK COLON_TK data_type			{ $$ = template("%s, %s %s", $1, $5, $3); }
		;

identifier1:	IDENTIFIER_TK							{ $$ = template("%s", $1); }
		|identifier1 COMMA_TK IDENTIFIER_TK				{ $$ = template("%s, %s", $1,$3); }
		;		

variables_declaration0:	/*empty*/ 						{ $$ = ""; }
		|VAR_TK variables_declaration 					{ $$ = $2; }
		;

variables_declaration:	/*empty*/ 							{ $$ = ""; }
		|variables_declaration identifier1 COLON_TK data_type SEMICOLON_TK	{ $$ = template("%s%s %s;\n", $1,$4,$2); }
		|variables_declaration identifier1 COLON_TK IDENTIFIER_TK SEMICOLON_TK 	{ $$ = template("%s%s %s;\n", $1,$4,$2); }
		;

subprograms:/*empty*/							{ $$ = ""; }
		|subprograms 	subprograms_declaration			
types																			
variables_declaration0															
subprograms																		
main_code SEMICOLON_TK		{ $$ = template("%s\n%s\n{\n%s\n%s\n%s\n%s\n}\n", $1,$2,$3,$4,$5,$6); }
		;

subprograms_declaration: 
PROCEDURE_TK IDENTIFIER_TK LEFT_BRACHET_TK parameters RIGHT_BRACHET_TK SEMICOLON_TK	{ $$ = template("void %s(%s)", $2,$4); }
|FUNCTION_TK IDENTIFIER_TK LEFT_BRACHET_TK parameters RIGHT_BRACHET_TK SEMICOLON_TK	{ $$ = template("void %s(%s)", $2,$4); }
|FUNCTION_TK IDENTIFIER_TK LEFT_BRACHET_TK parameters RIGHT_BRACHET_TK COLON_TK data_type SEMICOLON_TK										{ $$ = template("%s %s(%s)", $7,$2,$4); }
		;

parameters:	/*empty*/											{ $$ = ""; }
		|identifier1 COLON_TK data_type						{ $$ = template("%s %s", $3,$1); }
		|identifier1 COLON_TK IDENTIFIER_TK					{ $$ = template("%s %s", $3,$1); }
		|parameters SEMICOLON_TK identifier1 COLON_TK data_type			{ $$ = template("%s, %s %s", $1,$5,$3); }
		|parameters SEMICOLON_TK identifier1 COLON_TK IDENTIFIER_TK		{ $$ = template("%s, %s %s", $1,$5,$3); }
		;		

main_code:	BEGIN_TK body0 END_TK 		{$$ = template("%s", $2); }
		;	

body0:	/*empty*/					{ $$ = ""; }
		|body					{ $$ = $1; }
		;

body:	body1 SEMICOLON_TK 	body			{ $$ = template("%s\n%s", $1,$3); }
		|body1					{ $$ = $1; }
		; 

body1: 	body_assignment						{ $$ = $1; }
		|body_if 					{ $$ = $1; }
		|body_for 					{ $$ = $1; }
		|body_while 					{ $$ = $1; }
		|body_goto					{ $$ = $1; }
		|body_label					{ $$ = $1; }
		|body_return					{ $$ = $1; }
		|body_sub					{ $$ = $1; }
		;

body_assignment:  identifier1 ENTRASMENT_TK expression3		{ $$ = template("%s = %s;", $1,$3); } 
		|RESULT_TK ENTRASMENT_TK expression3		{ $$ = template("%s = %s;", $1,$3); }
		;		

s:	main_code		{ $$ = $1; }
	| body1			{ $$ = $1; }
	;

body_if: IF_TK expression3 THEN_TK s else_pt			{ $$ = template("if (%s)\n{\n\t%s\n}\n%s", $2,$4,$5); }
		;

else_pt: 	/*empty*/					{ $$ = ""; }
		|	ELSE_TK s				{ $$ = template("else\n{\n\t%s\n}\n", $2); }
		;

body_for: 	FOR_TK IDENTIFIER_TK ENTRASMENT_TK expression3 TO_TK expression3 DO_TK s			
		{ $$ = template("for(%s = %s ; %s < %s ; %s++)\n{\t\n%s\n}\n", $2, $4, $2, $6, $2, $8); }
		|FOR_TK IDENTIFIER_TK ENTRASMENT_TK expression3 DOWNTO_TK expression3 DO_TK s		
		{ $$ = template("for(%s = %s ; %s > %s ; %s--)\n{\t\n%s\n}\n", $2, $4, $2, $6, $2, $8); }
		;

body_while: WHILE_TK expression3 DO_TK s			
		{ $$ = template("while ( %s )\n{\n\t%s\n}\n", $2, $4); }
		|REPEAT_TK s UNTIL_TK expression3		
		{ $$ = template("do\n{\n\t%s\n}\nwhile ( %s )", $2, $4); }
		;
	
body_goto: GOTO_TK IDENTIFIER_TK						{ $$ = template("goto %s;", $2); }
		;										

body_return: RETURN_TK								{ $$ = template("return;"); }
		|RETURN_TK expression3						{ $$ = template("return %s;", $2); }
		;

body_label: IDENTIFIER_TK COLON_TK s						{ $$ = template("%s:", $1); }
		;		

body_sub: 	IDENTIFIER_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("%s(%s);", $1,$3); }
		|READSTRING_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("gets();"); }
		|READINT_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("atoi(gets());"); }
		|READREAL_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("atof(gets());"); }
		|WRITESTRING_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("puts(%s);", $3); }
		|WRITEINT_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("printf(\"%%d\", %s);", $3); }
		|WRITEREAL_TK LEFT_BRACHET_TK exp1 RIGHT_BRACHET_TK		{$$ = template("printf(\"%%g\", %s);", $3); }
		;

exp1:	{ $$ = ""; }
		|expression3							{ $$ = $1; }
		|identifier1							{ $$ = $1; }
		|RESULT_TK							{ $$ = template("result"); }
		|exp1 COMMA_TK expression3					{ $$ = template("%s, %s", $1, $3); }
		|exp1 COMMA_TK identifier1					{ $$ = template("%s, %s", $1, $3); }
		|exp1 COMMA_TK RESULT_TK					{ $$ = template("%s, result", $1); }
		;		

data_type:	BOOLEAN_TK				{ $$ = template("int"); }
		|CHAR_TK				{ $$ = template("char"); }
		|INTEGER_TK				{ $$ = template("int"); }
		|REAL_TK				{ $$ = template("double"); }

		|ARRAY_TK matrix OF_TK BOOLEAN_TK	{ $$ = template("boolean%s", $2);}
		|ARRAY_TK matrix OF_TK CHAR_TK		{ $$ = template("char%s", $2);}
		|ARRAY_TK matrix OF_TK INTEGER_TK	{ $$ = template("int%s", $2);}
		|ARRAY_TK matrix OF_TK REAL_TK		{ $$ = template("double%s", $2);}
		|ARRAY_TK matrix OF_TK IDENTIFIER_TK	{ $$ = template("%s%s", $4,$2);}


		|ARRAY_TK OF_TK BOOLEAN_TK		{ $$ = template("boolean*");}
		|ARRAY_TK OF_TK CHAR_TK			{ $$ = template("char*");}
		|ARRAY_TK OF_TK INTEGER_TK		{ $$ = template("int*");}
		|ARRAY_TK OF_TK REAL_TK			{ $$ = template("real*");}
		|ARRAY_TK OF_TK IDENTIFIER_TK		{ $$ = template("%s*");}

		|IDENTIFIER_TK LEFT_BRACHET_TK exp RIGHT_BRACHET_TK COLON_TK IDENTIFIER_TK	{ $$ = template("%s(*)(%s)", $6, $3);}
		|IDENTIFIER_TK LEFT_BRACHET_TK exp RIGHT_BRACHET_TK COLON_TK data_type		{ $$ = template("%s(*)(%s)", $6, $3);}

		|FUNCTION_TK LEFT_BRACHET_TK exp RIGHT_BRACHET_TK COLON_TK IDENTIFIER_TK	{ $$ = template("%s(*)(%s)", $6, $3);}
		|FUNCTION_TK LEFT_BRACHET_TK exp RIGHT_BRACHET_TK COLON_TK data_type		{ $$ = template("%s(*)(%s)", $6, $3);}
		;

%%

main (void)
{
  if ( yyparse() == 0)
     printf("\nYour program is syntactically correct!\n");
  else
     printf("\nYour program is syntactically incorrect!\n");
     return 0;
} 

yyerror(char const*s){
			extern char* yytext;
			printf("\nProgram terminated, because of %s in line %d on '%s' \n",s ,line_number,yytext );
}
