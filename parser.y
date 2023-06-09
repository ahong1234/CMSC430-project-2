/* Compiler Theory and Design
   Dr. Duane J. Jarc 
   Modified by Alex Hong
   Due: 04/11/23
   CMSC430
   Modified parser.y to support multiple variables, multiple optional 
   parameters in the function header, error handling and other
   requirements specified by the requirements for project 2.
   */

%{

#include <string>

using namespace std;

#include "listing.h"

int yylex();
void yyerror(const char* message);

%}

%error-verbose

%token IDENTIFIER
%token INT_LITERAL BOOL_LITERAL REAL_LITERAL

%token ADDOP MULOP RELOP ANDOP REMOP OROP EXPOP NOTOP

%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS

%token ARROW CASE ELSE ENDCASE ENDIF IF OTHERS REAL THEN WHEN 



%%

function:	
	function_header optional_variable body 
	;
	
function_header:	
	FUNCTION IDENTIFIER optional_parameters RETURNS type ';' 
	| error ';'
	;

optional_variable:
	optional_variable variable 
	|
	;

variable:
	IDENTIFIER ':' type IS statement_ 
	| error ';' 
	;

optional_parameters:
	params
	|
	;

params:
	params ',' parameter 
	| parameter 
	;

parameter:
	IDENTIFIER ':' type
	;

type:
	INTEGER |
	REAL |
	BOOLEAN ;

body:
	BEGIN_ statement_ END ';' ;
    
statement_:
	statement ';' 
	| error ';' ;
	
statement:
	expression 
	| REDUCE operator reductions ENDREDUCE
	| IF expression THEN statement_ ELSE statement_ ENDIF 
	| CASE expression IS case OTHERS ARROW statement_ ENDCASE 
	 ;

case: 
	case WHEN INT_LITERAL ARROW statement_ 
	| error ';'
	|
	; 

operator:
	ADDOP 
	| MULOP 
	;

reductions:
	reductions statement_
	| 
	;
		    
expression:
	expression OROP and
	| and ;

and:
	and ANDOP relation 
	| relation
	;

relation:
	relation RELOP term |
	term
	;

term:
	term ADDOP factor |
	factor ;
      
factor:
	factor MULOP exponent |
	factor REMOP exponent |
	exponent 
	;

exponent: 
	exponent EXPOP unary
	| exponent '(' unary ')'
	| unary
	;

unary: 
	not primary 
	| primary
	;

not: // recursive not
	not NOTOP 
	| NOTOP
	;

primary:
	'(' expression ')' |
	INT_LITERAL | 
	REAL_LITERAL |
	BOOL_LITERAL | 
	IDENTIFIER 
	;
    
%%

void yyerror(const char* message)
{
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[])    
{
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 
