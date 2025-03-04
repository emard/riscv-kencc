%{
#include "a.h"
%}
%union	{
	Sym	*sym;
	long	lval;
	double	dval;
	char	sval[8];
	Addr	addr;
	Gen	gen;
	Gen2	gen2;
}
%left	'|'
%left	'^'
%left	'&'
%left	'<' '>'
%left	'+' '-'
%left	'*' '/' '%'
%token	<lval>	LTYPE1 LTYPE2 LTYPE3 LTYPE4 LTYPE5
%token	<lval>	LTYPE6 LTYPE7 LTYPE8 LTYPE9 LTYPEA LTYPEB
%token	<lval>	LCONST LSP LSB LFP LPC LTOS LAREG LDREG LFREG LWID
%token	<dval>	LFCONST
%token	<sval>	LSCONST
%token	<sym>	LNAME LLAB LVAR
%type	<lval>	con expr scale type pointer reg offset
%type	<addr>	name areg xreg
%type	<gen>	gen rel
%type	<gen2>	noaddr gengen dstgen spec1 spec2 spec3 srcgen dstrel genrel
%%
prog:
|	prog line

line:
	LLAB ':'
	{
		if($1->value != pc)
			yyerror("redeclaration of %s", $1->name);
		$1->value = pc;
	}
	line
|	LNAME ':'
	{
		$1->type = LLAB;
		$1->value = pc;
	}
	line
|	';'
|	inst ';'
|	error ';'

inst:
	LNAME '=' expr
	{
		$1->type = LVAR;
		$1->value = $3;
	}
|	LVAR '=' expr
	{
		if($1->value != $3)
			yyerror("redeclaration of %s", $1->name);
		$1->value = $3;
	}
|	LTYPE1 gengen	{ outcode($1, &$2); }
|	LTYPE2 noaddr	{ outcode($1, &$2); }
|	LTYPE3 dstgen	{ outcode($1, &$2); }
|	LTYPE4 spec1	{ outcode($1, &$2); }
|	LTYPE5 srcgen	{ outcode($1, &$2); }
|	LTYPE6 dstrel	{ outcode($1, &$2); }
|	LTYPE7 genrel	{ outcode($1, &$2); }
|	LTYPE8 dstgen	{ outcode($1, &$2); }
|	LTYPE8 gengen	{ outcode($1, &$2); }
|	LTYPE9 noaddr	{ outcode($1, &$2); }
|	LTYPE9 dstgen	{ outcode($1, &$2); }
|	LTYPEA spec2	{ outcode($1, &$2); }
|	LTYPEB spec3	{ outcode($1, &$2); }

noaddr:
	{
		$$.from = nullgen;
		$$.to = nullgen;
	}
|	','
	{
		$$.from = nullgen;
		$$.to = nullgen;
	}

srcgen:
	gen
	{
		$$.from = $1;
		$$.to = nullgen;
	}
|	gen ','
	{
		$$.from = $1;
		$$.to = nullgen;
	}

dstgen:
	gen
	{
		$$.from = nullgen;
		$$.to = $1;
	}
|	',' gen
	{
		$$.from = nullgen;
		$$.to = $2;
	}

gengen:
	gen ',' gen
	{
		$$.from = $1;
		$$.to = $3;
	}

dstrel:
	rel
	{
		$$.from = nullgen;
		$$.to = $1;
	}
|	',' rel
	{
		$$.from = nullgen;
		$$.to = $2;
	}

genrel:
	gen ',' rel
	{
		$$.from = $1;
		$$.to = $3;
	}

spec1:	/* DATA opcode */
	gen '/' con ',' gen
	{
		$1.displace = $3;
		$$.from = $1;
		$$.to = $5;
	}

spec2:	/* bit field opcodes */
	gen ',' gen ',' con ',' con
	{
		$1.field = $7;
		$3.field = $5;
		$$.from = $1;
		$$.to = $3;
	}

spec3:	/* TEXT opcode */
	gengen
|	gen ',' con ',' gen
	{
		$1.displace = $3;
		$$.from = $1;
		$$.to = $5;
	}

rel:
	con '(' LPC ')'
	{
		$$ = nullgen;
		$$.type = D_BRANCH;
		$$.offset = $1 + pc;
	}
|	LNAME offset
	{
		$$ = nullgen;
		if(pass == 2)
			yyerror("undefined label: %s", $1->name);
		$$.type = D_BRANCH;
		$$.sym = $1;
		$$.offset = $2;
	}
|	LLAB offset
	{
		$$ = nullgen;
		$$.type = D_BRANCH;
		$$.sym = $1;
		$$.offset = $1->value + $2;
	}

gen:
	type
	{
		$$ = nullgen;
		$$.type = $1;
	}
|	'$' con
	{
		$$ = nullgen;
		$$.type = D_CONST;
		$$.offset = $2;
	}
|	'$' name
	{
		$$ = nullgen;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $2;
		}
		if($2.type == D_AUTO || $2.type == D_PARAM)
			yyerror("constant cannot be automatic: %s",
				$2.sym->name);
		$$.type = $2.type | I_ADDR;
	}
|	'$' LSCONST
	{
		$$ = nullgen;
		$$.type = D_SCONST;
		memcpy($$.sval, $2, sizeof($$.sval));
	}
|	'$' LFCONST
	{
		$$ = nullgen;
		$$.type = D_FCONST;
		$$.dval = $2;
	}
|	'$' '-' LFCONST
	{
		$$ = nullgen;
		$$.type = D_FCONST;
		$$.dval = -$3;
	}
|	LTOS '+' con
	{
		$$ = nullgen;
		$$.type = D_STACK;
		$$.offset = $3;
	}
|	LTOS '-' con
	{
		$$ = nullgen;
		$$.type = D_STACK;
		$$.offset = -$3;
	}
|	con
	{
		$$ = nullgen;
		$$.type = D_CONST | I_INDIR;
		$$.offset = $1;
	}
|	'-' '(' LAREG ')'
	{
		$$ = nullgen;
		$$.type = $3 | I_INDDEC;
	}
|	'(' LAREG ')' '+'
	{
		$$ = nullgen;
		$$.type = $2 | I_INDINC;
	}
|	areg
	{
		$$ = nullgen;
		$$.type = $1.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $1;
		}
		if(($$.type & D_MASK) == D_NONE) {
			$$.index = D_NONE | I_INDEX1;
			$$.scale = 0;
			$$.displace = 0;
		}
	}
|	areg xreg
	{
		$$ = nullgen;
		$$.type = $1.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $1;
		}
		$$.index = $2.type | I_INDEX1;
		$$.scale = $2.offset;
	}
|	'(' areg ')' xreg
	{
		$$ = nullgen;
		$$.type = $2.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $2;
		}
		$$.index = $4.type | I_INDEX2;
		$$.scale = $4.offset;
		$$.displace = 0;
	}
|	con '(' areg ')' xreg
	{
		$$ = nullgen;
		$$.type = $3.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $3;
		}
		$$.index = $5.type | I_INDEX2;
		$$.scale = $5.offset;
		$$.displace = $1;
	}
|	'(' areg ')'
	{
		$$ = nullgen;
		$$.type = $2.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $2;
		}
		$$.index = D_NONE | I_INDEX3;
		$$.scale = 0;
		$$.displace = 0;
	}
|	con '(' areg ')'
	{
		$$ = nullgen;
		$$.type = $3.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $3;
		}
		$$.index = D_NONE | I_INDEX3;
		$$.scale = 0;
		$$.displace = $1;
	}
|	'(' areg xreg ')'
	{
		$$ = nullgen;
		$$.type = $2.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $2;
		}
		$$.index = $3.type | I_INDEX3;
		$$.scale = $3.offset;
		$$.displace = 0;
	}
|	con '(' areg xreg ')'
	{
		$$ = nullgen;
		$$.type = $3.type;
		{
			Addr *a;
			a = (Addr*)&$$;
			*a = $3;
		}
		$$.index = $4.type | I_INDEX3;
		$$.scale = $4.offset;
		$$.displace = $1;
	}

type:
	reg
|	LFREG

xreg:
	/*
	 *	.W*1	0
	 *	.W*2	1
	 *	.W*4	2
	 *	.W*8	3
	 *	.L*1	4
	 *	.L*2	5
	 *	.L*4	6
	 *	.L*8	7
	 */
	'(' reg LWID scale ')'
	{
		$$.type = $2;
		$$.offset = $3+$4;
		$$.sym = S;
	}

reg:
	LAREG
|	LDREG
|	LTOS

scale:
	'*' con
	{
		switch($2) {
		case 1:
			$$ = 0;
			break;

		case 2:
			$$ = 1;
			break;

		default:
			yyerror("bad scale: %ld", $2);

		case 4:
			$$ = 2;
			break;

		case 8:
			$$ = 3;
			break;
		}
	}

areg:
	'(' LAREG ')'
	{
		$$.type = $2 | I_INDIR;
		$$.sym = S;
		$$.offset = 0;
	}
|	con '(' LAREG ')'
	{
		$$.type = $3 | I_INDIR;
		$$.sym = S;
		$$.offset = $1;
	}
|	'(' ')'
	{
		$$.type = D_NONE | I_INDIR;
		$$.sym = S;
		$$.offset = 0;
	}
|	con '(' ')'
	{
		$$.type = D_NONE | I_INDIR;
		$$.sym = S;
		$$.offset = $1;
	}
|	name

name:
	LNAME offset '(' pointer ')'
	{
		$$.type = $4;
		$$.sym = $1;
		$$.offset = $2;
	}
|	LNAME '<' '>' offset '(' LSB ')'
	{
		$$.type = D_STATIC;
		$$.sym = $1;
		$$.offset = $4;
	}

offset:
	{
		$$ = 0;
	}
|	'+' con
	{
		$$ = $2;
	}
|	'-' con
	{
		$$ = -$2;
	}

pointer:
	LSB
|	LSP
|	LFP

con:
	LCONST
|	LVAR
	{
		$$ = $1->value;
	}
|	'-' con
	{
		$$ = -$2;
	}
|	'+' con
	{
		$$ = $2;
	}
|	'~' con
	{
		$$ = ~$2;
	}
|	'(' expr ')'
	{
		$$ = $2;
	}

expr:
	con
|	expr '+' expr
	{
		$$ = $1 + $3;
	}
|	expr '-' expr
	{
		$$ = $1 - $3;
	}
|	expr '*' expr
	{
		$$ = $1 * $3;
	}
|	expr '/' expr
	{
		$$ = $1 / $3;
	}
|	expr '%' expr
	{
		$$ = $1 % $3;
	}
|	expr '<' '<' expr
	{
		$$ = $1 << $4;
	}
|	expr '>' '>' expr
	{
		$$ = $1 >> $4;
	}
|	expr '&' expr
	{
		$$ = $1 & $3;
	}
|	expr '^' expr
	{
		$$ = $1 ^ $3;
	}
|	expr '|' expr
	{
		$$ = $1 | $3;
	}
