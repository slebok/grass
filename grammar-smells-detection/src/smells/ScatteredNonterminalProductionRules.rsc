module smells::ScatteredNonterminalProductionRules

import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Relation;
import Map::Extra;
import List;
import Violations;
import lang::json::IO;
import GrammarInformation;

set[Violation] violations(grammarInfo(grammar(ns,ps,_), grammarData(r, nprods, _, _, _), _)) =
	{ <violatingNonterminal(n), scatteredNonterminal()>
	| n <- ns
	, isScattered(ps, nprods[n])
	};
	

bool isScattered(list[GProd] haystack, list[GProd] needles) {
	set[int] indexes = { i | <p,i> <- zip(haystack,index(haystack)), p in needles};
	return (max(indexes) - min(indexes)) >= size(needles); 
}


void export(list[tuple[loc, GrammarInfo, set[Violation]]] triples) {
	lrel[loc,str] scatteredData = [ <l, n> | <l,g,vs> <- triples, <violatingNonterminal(n), scatteredNonterminal()> <- vs];
	list[list[value]] scattered = [ ["<a>",b] | <a,b> <- scatteredData];
	IO::writeFile(|project://grammarsmells/output/scattered-nonterminals.json|, toJSON(scattered, true));
	
}