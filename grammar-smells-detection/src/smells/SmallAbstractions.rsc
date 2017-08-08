module smells::SmallAbstractions

import grammarlab::language::Grammar;
import GrammarUtils;
import List;
import Set;
import IO;
import ListRelation;
import Violations;
import GrammarInformation;
import lang::json::IO;
import smells::Size;

set[Violation] violations(grammarInfo(g:grammar(ns,_,_), grammarData(refs, nprods, expressionIndex, tops, _), _)) {
    lrel[GProd, str] refers = prodReferences(g);
    refersInvert = invert(refers);
	return
		{ <violatingNonterminal(n), singleUsageNonterminal(prodsForN[0])>
		| n <- range(prodReferences(g))
		, n in ns
		, prodsForN := nprods[n]
		, size(prodsForN) == 1
		, size(refersInvert[n]) == 1
		, size(refs[n]) == 0
		};
}

map[str,value] buildNonterminalInfo(GProd p) {
	return 
		( "nonterminal" : p.lhs
		, "info" : smells::Size::buildProductionInfo(p)
		);
}
void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	smallAbstractionData = for(<l, gInfo,vs> <- triples) {
	
		list[map[str,value]] nonterminalInfos =
			[ buildNonterminalInfo(p)
			| <violatingNonterminal(n), singleUsageNonterminal(p)> <- vs
			];
		
		append
			( "location" : "<l>"
			, "nonterminals": nonterminalInfos
			);
	}
	
	IO::writeFile(
		|project://grammarsmells/output/small-abstractions.json|,
		toJSON( smallAbstractionData, true)
	);
}