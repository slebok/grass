module smells::MixedTop


import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Relation;
import Map::Extra;
import List;
import Violations;
import GrammarInformation;
import lang::json::IO;

set[Violation] violations(grammarInfo(grammar(_, ps, starts), grammarData(_, _, expressionIndex, tops, _), _)) {
	list[str] prodNs = [ lhs | production(lhs,_) <- ps];
	set[str] allowed = tops + toSet(starts);
	
	if(prodNs == []) {
		return {};
	}
	set[str] firstAndLast = {head(prodNs), last(prodNs)};
	
	if (allowed != {} && (firstAndLast & allowed) == {}) {
		return 
			{ < violatingNonterminals({ head(prodNs), last(prodNs)} + allowed)
			  , mixedTops()
			  >
			};
	}  else {
		return {};
	}
}

void export(list[tuple[loc, GrammarInfo, set[Violation]]] triples) {
	list[list[value]] mixedTopData = [ ["<l>", toList(ns)] | <l,g,vs> <- triples, <violatingNonterminals(ns), mixedTops()> <- vs];
	IO::writeFile(|project://grammarsmells/output/mixed-tops.json|, toJSON(mixedTopData, true));	
}