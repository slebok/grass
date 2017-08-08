module smells::ExplicitAmbiguity


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
import grammarlab::export::Grammar;

void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	list[map[str,value]] explicitAmbiguityData; 
	explicitAmbiguityData = for(<l, gInfo, vs> <- triples) {
		
		//println("<l>");
		//for (<violatingProduction(p), explicitAmbiguity(_, notViaEpsilon)> <- vs, notViaEpsilon) {
		//	println("<ppx(p)>");
		//}
		
		append (
			"location" : "<l>",
			"violations" :
				toList(
					{ [ p.lhs
					  , indexOf(gInfo.g.P, p)
					  , notViaEpsilon
					  ]
					|  <violatingProduction(p), explicitAmbiguity(_, notViaEpsilon)> <- vs
					}
				)
		);
	}
	IO::writeFile(
		|project://grammarsmells/output/explicit-ambiguity.json|,
		toJSON( explicitAmbiguityData, true)
	);
}

list[GExpr] withoutEpsilon(list[GExpr] xs) = [x | x <- xs, epsilon() != x ];
list[GExpr] withoutVal(list[GExpr] xs) = [x | x <- xs, /val(_) !:= x ];


set[Violation] violations(grammarInfo(GGrammar g, grammarData(r, _, expressionIndex, tops,_), facts)) {
	
	return  
	    { <violatingProduction(occ.p), explicitAmbiguity(k, size(toSet(withoutVal(withoutEpsilon(opts)))) != size(withoutVal(withoutEpsilon(opts))) )>
		| occurence <- expressionIndex
		, fullExpr(k) := occurence
		, choice(opts) := k
		, size(toSet(opts)) != size(opts)
		, occs := expressionIndex[occurence]
		, occ <- occs 
		};
}