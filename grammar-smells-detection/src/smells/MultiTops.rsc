module smells::MultiTops

import grammarlab::language::Grammar;
import GrammarUtils;
import List;
import Set;
import util::Math;
import IO;
import Violations;
import lang::json::IO;
import GrammarInformation;
import Relation;
import Set;

set[Violation] violations(GrammarInfo gInfo) {
	if (gInfo.g.S != []) {
		if (size(gInfo.g.S) > 1 && gInfo.d.tops - toSet(gInfo.g.S) != {}) {
			iprintln("SOME! <gInfo.d.tops - toSet(gInfo.g.S)>");
			return {<violatingNonterminals(toSet(gInfo.g.S)), multiTops()>}; 
		} else {
			return {};
		}
	} else if (size(gInfo.d.tops) > 1) {
		return {<violatingNonterminals(gInfo.d.tops), multiTops()>}; 
	} else if (size(gInfo.d.tops) == 0 && gInfo.g.S == []) {
		languageLevels(levelParts,levelRel) = gInfo.d@levels;
		
		return {<violatingNonterminals({}), noTops(levelParts - range(levelRel))>};
	} else {
		return {};
	}
}

bool fullyConnected(GrammarInfo gInfo) {
	languageLevels(levelParts,levelRel) = gInfo.d@levels;
	rel[set[str],set[str]] levelRelPlus = (levelRel + invert(levelRel))+;
	result =  size(levelParts) == 1 || levelRelPlus[getOneFrom(levelParts)] == levelParts;
	return result;
	
}
void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	noTopData = 
		[ ("location": "<l>", "topLevels" : [ toList(topLevel) | topLevel <- topLevels] )
		| <l, gInfo, vs > <- triples
		, <violatingNonterminals(ns),noTops(topLevels)> <- vs
		];
		
		
	multiTopData = 
		[ ("location": "<l>", "nonterminals" : toList(ns)
		  , "starts" : gInfo.g.S
		  , "tops": toList(gInfo.d.tops)
		  , "connected" : fullyConnected(gInfo)
		  )
		| <l, gInfo, vs > <- triples
		, languageLevels(levelParts,levelRel) := gInfo.d@levels
		, <violatingNonterminals(ns),multiTops()> <- vs
		];
	
	IO::writeFile(
		|project://grammarsmells/output/no-tops.json|,
		toJSON( noTopData, true)
	);
	
	IO::writeFile(
		|project://grammarsmells/output/multi-tops.json|,
		toJSON( multiTopData, true)
	);
}
