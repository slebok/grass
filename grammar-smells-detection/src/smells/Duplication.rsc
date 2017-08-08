module smells::Duplication

import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import Violations;
import List;
import GrammarInformation;
import lang::json::IO;
import Size;
import Relation;

bool isNonterminal(ExpressionOccurence x) {
	if (fullExpr(nonterminal(_)) := x) {
		return true;
	} else if (partialExpr([nonterminal(_)]) := x) {
		return true;
	} else {
		return false;
	}
}

bool isTerminal(ExpressionOccurence x) {
	if (fullExpr(terminal(_)) := x) {
		return true;
	} else if (partialExpr([terminal(_)]) := x) {
		return true;
	} else {
		return false;
	}
}

set[set[GProd]] duplicateProductionRules(map[ExpressionOccurence, list[ExpressionOccurenceLocation]] index) {
	return { l | k <- index, fullExpr(m) := k, l := { v | occurenceRule(v) <- index[k]}, size(l) > 1, /val(_) !:= m, epsilon() !:= m };
}

rel[GExpr, GProd, GProd] knownSubexpression(map[ExpressionOccurence, list[ExpressionOccurenceLocation]] index) = 
	( {}
	| it + 
		{ <l, s, r> 
		| n <- index[k]
		, occurenceRule(r) := n
		, m <- index[k]
		, occurenceSubExpr(s) := m
		}
	| k <- index
	, size(index[k]) > 1
	, fullExpr(l) := k
	, nonterminal(_) !:= l
	, /val(_) !:= l
	, epsilon() !:= l
	, anything() !:= l
	);

rel[GExpr, set[GProd]] commonSubexpressions(map[ExpressionOccurence, list[ExpressionOccurenceLocation]] index) {
	set[tuple[GExpr, GProd, GProd]] triples =
		( {}
		| it + 
			{ <full,s,r> 
			| n <- index[k]
			, occurenceSubExpr(r) := n
			, m <- index[k]
			, occurenceSubExpr(s) := m
			, r != s
			}
		| k <- index
		, size(index[k]) > 1
		, fullExpr(full) := k
		, nonterminal(_) !:= full
		, terminal(_) !:= full
		, /val(_) !:= full
		, epsilon() !:= full
		, anything() !:= full
		);
	map[GExpr, set[GProd]] indexedExpressions = ( () | addItemToValueSet(addItemToValueSet(it, a, b), a, c) | <a,b,c> <- triples );
	return { <k, indexedExpressions[k]> | k <- indexedExpressions};
}

set[Violation] violations(grammarInfo(g, grammarData(_, _, expressionIndex,_,_), facts)) {
	rel[GExpr, GProd, GProd] knowns = knownSubexpression(expressionIndex);
	 
	return { <violatingProductions(rules), duplicateRules()> | rules <- duplicateProductionRules(expressionIndex) }
	+ { <violatingProductions(b + c), definedSubExpression(a,b,c)>
	  | a <- domain(knowns), b := domain(knowns[a]), c := range(knowns[a])}
	//{ <violatingProductions({b,c}), definedSubExpression(a,b,c)> | <a,b,c> <- knownSubexpression(expressionIndex)}
	+ { <violatingProductions(xs), commonSubExpression(a)> | <a,xs> <- commonSubexpressions(expressionIndex)}
	;
}
	
test bool testCommonSubexpressions1() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B","C"],
		[ production("A", plus(nonterminal("C")))
		, production("B", plus(nonterminal("C")))
		, production("C", terminal("D"))
		],
		[]));
		
	return commonSubexpressions(i.d.exprIndex) == {};
}
	
test bool testCommonSubexpressions2() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B","C"],
		[ production("A", star(plus(nonterminal("C"))))
		, production("B", plus(nonterminal("C")))
		, production("C", terminal("D"))
		],
		[]));
		
	return commonSubexpressions(i.d.exprIndex) == {};
}


test bool testCommonSubexpressions3() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B","C"],
		[ production("A", star(val(string())))
		, production("B", star(val(string())))
		],
		[]));
	return commonSubexpressions(i.d.exprIndex) == {};
}
	
		
test bool testKnownSubexpressions1() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B","C"],
		[ production("A", plus(nonterminal("C")))
		, production("B", plus(nonterminal("C")))
		, production("C", terminal("D"))
		],
		[]));
		
	return knownSubexpression(i.d.exprIndex) == {};
}

test bool testKnownSubexpressions2() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B","C"],
		[ production("A", star(plus(nonterminal("C"))))
		, production("B", plus(nonterminal("C")))
		, production("C", terminal("D"))
		],
		[]));
		
	return knownSubexpression(i.d.exprIndex) == 
		{ < plus(nonterminal("C"))
		  , production("A", star(plus(nonterminal("C"))))
		  , production("B",plus(nonterminal("C")))
		  >
		}
    ;
}

test bool testKnownSubexpressions3() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B"],
		[ production("A", star(val(string())))
		, production("B", val(string()))
		],
		[]));
		
	return knownSubexpression(i.d.exprIndex) == {};
}


//Export


void export(lrel[loc, GrammarInfo, set[Violation]] pairs) {
	list[map[str,value]] duplicateData = [];
	duplicateData = for( <l, gInfo, vs> <- pairs) {
		rel[GExpr, set[GProd], set[GProd]] definedSubexpressions = { <a,b,c> | <_,definedSubExpression(a,b,c)> <- vs};
		set[GExpr] commonSubExprs = { a | <_,commonSubExpression(a)> <- vs};
		
		list[value] duplicateRules = 
			[ ( "size": Size::expressionSize(getOneFrom(x).rhs)
			  , "nonterminals" :
			  		[ [ p.lhs, indexOf(gInfo.g.P, p) ]
					| p <- x
					] 
			  )
			| <violatingProductions(x), duplicateRules()> <- vs
			];
		
		list[value] duplicateRulesNotNonterminals =
			[ ( "size": Size::expressionSize(getOneFrom(x).rhs)
			  , "nonterminals" :
			  		[ [ p.lhs, indexOf(gInfo.g.P, p) ]
					| p <- x
					] 
			  )
			| <violatingProductions(x), duplicateRules()> <- vs
			, nonterminal(_) !:= getOneFrom(x).rhs
			];
		


		//optional(nonterminal(_))
		//terminal(_)
		//optional(terminal(_))
		//plus(nonterminal(_))
		//star(nonterminal(_))
		
		list[value] definedSubExpressions =
			[ ( "size" : Size::expressionSize(a)
			  , "sources" : [ [ b.lhs, indexOf(gInfo.g.P, b) ] | b <- bs ]
			  , "targets": [ [ c.lhs, indexOf(gInfo.g.P, c) ] | c <- cs]
			  , "prodFacts" : 
		  		( "optionalNonterminal" : optional(nonterminal(_)) := c.rhs
		  		, "optionalTerminal" : optional(terminal(_)) := c.rhs
		  		, "plusTerminal" : plus(terminal(_)) := c.rhs
		  		, "plusNonterminal" : plus(nonterminal(_)) := c.rhs
		  		, "starTerminal" : star(terminal(_)) := c.rhs
		  		, "starNonterminal" : star(nonterminal(_)) := c.rhs
		  		, "terminal" : terminal(_) := c.rhs
		  		, "choice" : choice(_) := c.rhs
		  		, "sequence" : sequence(_) := c.rhs
		  		)
			  )
			| <a,bs,cs> <- definedSubexpressions
			, c := getOneFrom(cs)
			];
		
		list[value] commonSubExpression = 
			[ ( "size" : Size::expressionSize(a) 	
			  , "nonterminals" :
		  			[ [ p.lhs, i]
		  			| <p,i> <- zip(gInfo.g.P, index(gInfo.g.P))
		  			, /a := p.rhs
		  			] 
		  			)
			| a <- commonSubExprs
			];
			
		append (
			"location": "<l>",
			"duplicateRules": duplicateRules,			
			"duplicateRulesNotNonterminals": duplicateRulesNotNonterminals,
			"definedSubExpressions": definedSubExpressions,
			"commonSubExpressions": commonSubExpression
		);
	}
	
	IO::writeFile(
		|project://grammarsmells/output/duplication.json|,
		toJSON( duplicateData, true)
	);
	
}

int onlyNonterminalDuplicateRules(set[Violation] vs)
	= size({ g | <violatingProductions(g), duplicateRules()> <- vs, p := getOneFrom(g), nonterminal(_) := p.rhs});
	

	
	


	