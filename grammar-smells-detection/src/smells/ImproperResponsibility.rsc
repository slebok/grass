module smells::ImproperResponsibility

import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import List;
import Violations;
import lang::json::IO;
import Size;
import GrammarInformation;
import grammarlab::export::Grammar;

test bool testViolations1() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), nonterminal("C") ] ) )
		, production("B", sequence([nonterminal("D"), terminal("B")]))
		, production("C", sequence([nonterminal("D"), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations1withVal() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), nonterminal("C") ] ) )
		, production("B", sequence([nonterminal("D"), terminal("B")]))
		, production("C", sequence([nonterminal("D"), terminal("C")]))
		, production("D", sequence([val(string())]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [];
}


test bool testViolations1Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), nonterminal("C") ] ) )
		, production("B", sequence([nonterminal("D"), terminal("B")]))
		, production("C", sequence([nonterminal("D"), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations2() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "D"],
		[ production("A", choice(
				[ sequence([nonterminal("D"), terminal("B") ] )
				, sequence([nonterminal("D"), terminal("C") ] )
				] ) )
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations2Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "D"],
		[ production("A", choice(
				[ sequence([nonterminal("D"), terminal("B") ] )
				, sequence([nonterminal("D"), terminal("C") ] )
				] ) )
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [];
}

test bool testViolations3() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A"],
		[ production("A", choice(
				[ sequence([terminal("D"), terminal("B") ] )
				, sequence([terminal("D"), terminal("C") ] )
				] ) )
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations3Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A"],
		[ production("A", choice(
				[ sequence([terminal("D"), terminal("B") ] )
				, sequence([terminal("D"), terminal("C") ] )
				] ) )
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [];
}


test bool testViolations4() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), nonterminal("C") ] ) )
		, production("B", sequence([terminal("D"), terminal("B")])) // This one is different from the first test
		, production("C", sequence([nonterminal("D"), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations4Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), nonterminal("C") ] ) )
		, production("B", sequence([terminal("D"), terminal("B")])) // This one is different from the first test
		, production("C", sequence([nonterminal("D"), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [terminal("D")];
}

test bool testViolations5() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", sequence([nonterminal("A"), terminal("B")]))
		, production("C", sequence([terminal("C")]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [];
}


test bool testViolations5Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", sequence([nonterminal("A"), terminal("B")]))
		, production("C", sequence([terminal("C")]))
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [];
}

test bool testViolations6() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", choice([nonterminal("D"), terminal("B")]))
		, production("C", sequence([terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionNaive(i, i.g.P[0]) == [];
}

test bool testViolations6Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", choice([nonterminal("D"), terminal("B")]))
		, production("C", sequence([terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	return commonPathForProductionImplicit(i, i.g.P[0]) == [];
}


test bool testViolations7() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", choice([nonterminal("D"), terminal("B")]))
		, production("C", sequence([choice([nonterminal("D"), terminal("B")]), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	result = commonPathForProductionNaive(i, i.g.P[0]);
	return result == [choice([nonterminal("D"), terminal("B")])];
}

test bool testViolations7Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D"],
		[ production("A", choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ] ) )
		, production("B", choice([nonterminal("D"), terminal("B")]))
		, production("C", sequence([choice([nonterminal("D"), terminal("B")]), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	result = commonPathForProductionImplicit(i, i.g.P[0]);
	return result == [choice([nonterminal("D"), terminal("B")])];
}

test bool testViolations8Implicit() {
	GrammarInfo i = buildFromGrammar(grammar(
		["A", "B", "C", "D", "E"],
		[ production("A", sequence([terminal("E"), choice([nonterminal("B"), sequence([nonterminal("C"), terminal("A")]) ]) ]) )
		, production("B", choice([nonterminal("D"), terminal("B")]))
		, production("C", sequence([choice([nonterminal("D"), terminal("B")]), terminal("C")]))
		, production("D", sequence([terminal("D")]))
		],
		[]));
	result = commonPathForProductionImplicit(i, i.g.P[0]);
	return result == [terminal("E"), choice([nonterminal("D"), terminal("B")])];
}



list[GExpr] commonPathForProductionNaive(GrammarInfo gInfo, GProd p) {
	if (choice(xs) := p.rhs, size(xs) >= 2) {
		paths = [deterministicPathForExpr(gInfo, {p.lhs}, x) | x <- xs];
		return onlyTakeNonVals(longestHead(paths));
	} else {
		return [];
	}
}

list[GExpr] commonPathForProductionImplicit(GrammarInfo gInfo, GProd p) {
	if (choice(xs) := p.rhs, size(xs) >= 2) {
		seqs = [ exprAsSequential(x) | x <- xs];
		explicitHead = longestHead(seqs);
		if(/val(_) := explicitHead) {
			return [];
		}
		restExps = [ sequence(drop(size(explicitHead), x)) | x <- seqs];
		
		paths = [deterministicPathForExpr(gInfo, {p.lhs}, x) | x <- restExps];
		
		result = longestHead(paths);
		if (result == []) {
			return [];
		}
		return onlyTakeNonVals(explicitHead + result);
	} else if (sequence([h*,c:choice(xs),_*]) := p.rhs) {
		r = commonPathForProductionImplicit(gInfo, production(p.lhs, c));
		if (r != []) {
			return h + r;
		} else { 
			return [];
		}
	} else {
		return [];
	}
}


list[GExpr] onlyTakeNonVals(list[GExpr] xs) = takeWhile(xs, isNonVal);
bool isNonVal(val(_)) = false;
bool isNonVal(GExpr _) = true;

list[GExpr] deterministicPathForExpr(GrammarInfo gInfo, set[str] passedNs, GExpr e) {
	switch (e) {
		case sequence(xs): {
			return concat([ deterministicPathForExpr(gInfo, passedNs, x) | x <- xs ] ); 
		}
		case nonterminal(n): {
			if (n in passedNs) {
				return [e];
			} else if (gInfo.d.nprods[n]?) {
				return deterministicPathForExpr(gInfo, passedNs + n, prodAsExpr(gInfo.d.nprods[n]));
			} else {
				return [e];
			}
		}
		default:
			return [e];
	};
}

GExpr prodAsExpr([p]) = p.rhs;
GExpr prodAsExpr(list[GProd] ps) = choice(concat([ exprAsOptions(p.rhs) | p <- ps ]));		

list[GExpr] exprAsOptions(choice(xs)) = xs;
list[GExpr] exprAsOptions(e) = [e];

list[GExpr] exprAsSequential(sequence(xs)) = xs;
list[GExpr] exprAsSequential(e) = [e];


set[Violation] violations(gInfo:grammarInfo(g, grammarData(_, nprods, expressionIndex,_,_), _)) {
	result = for (p <- g.P) {
		c = commonPathForProductionNaive(gInfo, p);
		if (c != []) {
			append <violatingProduction(p), improperResponsibilityNaive(c)>;
		}
	}
	
	resultImplicit = for (p <- g.P) {
		c = commonPathForProductionImplicit(gInfo, p);
		if (c != []) {
			append <violatingProduction(p), improperResponsibilityImplicit(c)>;
		}
	}
	
	
	return toSet(result) + toSet(resultImplicit);
}

list[GExpr] longestHead(list[list[GExpr]] input) {
	list[GExpr] result = [];
	list[list[GExpr]] sequenced = input;
	while(all(s <- sequenced, head(s)?)) {
		heads = [ head(s) | s <- sequenced] ;
		if (size(dup(heads)) == 1) {
			result = result + getOneFrom(heads);
			sequenced = [ drop(1, s) | s <- sequenced ]; 
		}  else {
			break;
		}
	}
	return result; 	
}
list[GExpr] allHeads(map[str, list[GProd]] nprods, list[GExpr] xs, GGrammar theGrammar) =
	 [ headOfExpression(nprods, x, theGrammar, {}) | x <- xs ];



GExpr headOfExpression(map[str, list[GProd]] nprods, GExpr x, GGrammar theGrammar, set[str] viewed) =
	resolveNonterminal(nprods, firstExpr(x), theGrammar, viewed);
	
GExpr resolveNonterminal(map[str, list[GProd]] nprods, GExpr x, GGrammar theGrammar, set[str] viewed) {
	if (nonterminal(s) := x) {
		list[GProd] prods = nprods[s]? ? nprods[s] : [];
		if (size(prods) == 1) {
			production(lhs, rhs) = getOneFrom(prods);
			if (lhs in viewed) {
				return x;
			} else {
				return firstExpr(rhs);
			}
		} else {
			return choice([ rhs | prod <- prods, production(lhs,rhs) := prod ]);
		}
	} else {
		return x;
	}
}

GExpr firstExpr(GExpr x) {
	if (sequence(ys) := x) {
		return firstExpr(head(ys));
	} else {
	 	return x;
	}
}

//Export
void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	list[map[str,value]] exportDataNaive = [];
	exportDataNaive = for (<l, info,vs> <- triples) {
		list[tuple[GProd,list[GExpr]]] improperExprs = [ <x,y> | <violatingProduction(x),improperResponsibilityNaive(y)> <- vs ];
		
		//for (<x,y> <- improperExprs) {
		//	println("PPX: <sequence(y)>");
		//}
		
		append 
			( "location" : "<l>"
			, "improperExpressions" :
				[ ( "size": Size::expressionSize(sequence(y))
				  , "ns" : x.lhs
				  , "value": ppx(y)
				  )
				| <x,y> <- improperExprs
				]
			);
	}
	
	exportDataImplicit = for (<l, info,vs> <- triples) {
		list[tuple[GProd,list[GExpr]]] improperExprs = [ <x,y> | <violatingProduction(x),improperResponsibilityImplicit(y)> <- vs ];
		
		//for (<x,y> <- improperExprs) {
		//	println("PPX: <sequence(y)>");
		//}
		
		append 
			( "location" : "<l>"
			, "improperExpressions" :
				[ ( "size": Size::expressionSize(sequence(y))
				  , "ns" : x.lhs
				  , "value": ppx(y)
				  )
				| <x,y> <- improperExprs
				]
			);
	}
	
	
	exportData = 
		( "naive" : exportDataNaive
		, "implicit": exportDataImplicit
		);
	
	IO::writeFile(
		|project://grammarsmells/output/improper-responsibility.json|,
		toJSON( exportData, true)
	);
	
}
