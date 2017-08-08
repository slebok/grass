module smells::DisconnectedNonterminalGraph


import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Relation;
import Map::Extra;
import List;
import GrammarInformation;
import Violations;
import lang::json::IO;

void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	list[map[str,value]] disconnectedData; 
	disconnectedData = for(<l, gInfo, vs> <- triples) {
		append (
			"location" : "<l>",
			"tops" : toList(gInfo.d.tops),
			"nonterminals" : [ n | <violatingNonterminal(n), disconnectedFromTop()> <- vs],
			"starts": gInfo.g.S
		);
	}
	IO::writeFile(
		|project://grammarsmells/output/disconnected.json|,
		toJSON( disconnectedData, true)
	);
}


set[Violation] violations(grammarInfo(GGrammar g, grammarData(r, _, expressionIndex, tops,_), facts)) {
	set[str] excluded = tops +  toSet(g.S);
	rel[str,str] reflSymTranClos = (r + invert(r))+;
	indexed = index(reflSymTranClos);
	return  { <violatingNonterminal(n), disconnectedFromTop()> | n <- toSet(g.N), n notin excluded, ms := indexed[n], (ms & excluded) == {} };
}