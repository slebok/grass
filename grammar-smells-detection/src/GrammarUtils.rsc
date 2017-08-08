module GrammarUtils

import grammarlab::language::Grammar;
import IO;
import Set;
import Relation;
import Map::Extra;
import List;
import Map;
import Partitions;

data ExpressionOccurence
	= fullExpr(GExpr expr2)
	| partialExpr(list[GExpr] exprs)
	;

data ExpressionOccurenceLocation
	= occurenceRule(GProd p)
	| occurenceSubExpr(GProd p)
	| occurencePartial(GProd p)
	;
	
map[ExpressionOccurence, list[ExpressionOccurenceLocation]] buildExpressionIndex(grammar(_,ps,_)) =
	( () | registerExpressionsForProd(it, prod) | prod <- ps);	

map[ExpressionOccurence, list[ExpressionOccurenceLocation]] registerExpressionsForProd(map[ExpressionOccurence, list[ExpressionOccurenceLocation]] index, production(lhs, expr)) {
	index = addItemToValueList(index, fullExpr(expr), occurenceRule(production(lhs, expr)));
	
	int counter = 0;
	visit (expr) {
		case GExpr v: { 
			if (!(v == expr) ) {
				index = addItemToValueList(index, fullExpr(v), occurenceSubExpr(production(lhs, expr)));
				counter += 1;
			}
		}
	}
	return index;
}

test bool testRegisterExpressionsForProd1() = 
	registerExpressionsForProd((), production("PredicateTerm", plus(nonterminal("InWhereHolds")))) 
	==
	( fullExpr(nonterminal("InWhereHolds")):
		[ occurenceSubExpr(production("PredicateTerm",plus(nonterminal("InWhereHolds"))))]
	, fullExpr(plus(nonterminal("InWhereHolds"))):
		[ occurenceRule(production("PredicateTerm", plus(nonterminal("InWhereHolds"))))]
	)
	;

set[set[str]] languageLevels(GGrammar g) {
	refs = nonterminalReferences(g);
	return Partitions::partitionForTransitiveClosure(toSet(g.N) + domain(refs) + range(refs), refs+);
}

set[str] exprNonterminals(GExpr expr) {
	set[str] result = {};
	visit (expr) {
		case nonterminal(t): result = result + t;
	}
	return result;
}

map[str, list[GProd]] nonterminalProdMap(g:grammar(ns, ps, ss)) =
	( n : prodsForNonterminal(g, n) | n <- ns);
	
list[GProd] prodsForNonterminal(grammar(_,ps,_), str n) =
	[ p | p <- ps , p.lhs == n];


lrel[GProd, str] prodReferences(grammar(_,ps,_)) {
	return [ <production(lhs,rhs), n> | production(lhs,rhs) <- ps, n <- exprNonterminals(rhs)];
}

rel[str,str] nonterminalReferencesWithProdMap(GGrammar g:grammar(ns,_,_), map[str, list[GProd]] nprods) = 
	{ <n,m>
	| n <- ns
	, production(_,e) <- nprods[n]
	, m <- exprNonterminals(e)
	};
	
rel[str,str] nonterminalReferences(GGrammar g) =
	nonterminalReferencesWithProdMap(g, nonterminalProdMap(g));


list[str] orderedLhs(grammar(_,ps,_)) =
	[ lhs | production(lhs,_) <- ps];
	
set[str] grammarTops(GGrammar g:grammar(ns,_,_), rel[str,str] refs) =
	toSet(ns) - range(refs);

set[str] grammarBottoms(GGrammar g:grammar(ns,_,_), rel[str,str] refs) =
	range(refs) - toSet(ns);
