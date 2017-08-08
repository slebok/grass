module smells::SingleListThingy


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

set[Violation] violations(grammarInfo(grammar(_,ps,_), grammarData(_, _, _, _, _), _)) =
	{ <violatingProduction(p), singleListThingy(e)>
	| p <- ps
	, production(lhs, rhs) := p
	, /e:sequence([_]) := rhs || /e:choice([_]) := rhs
	};

void export(list[tuple[loc, GrammarInfo, set[Violation]]] input) {
	
	list[list[value]] singleListThingyData =
		[ ["<l>", indexOf(gInfo.g.P, p), p.lhs]
		| <l,gInfo,vs> <- input
		, <violatingProduction(p), singleListThingy(e)> <- vs
		];
	
	IO::writeFile(
		|project://grammarsmells/output/single-list-thingy.json|,
		toJSON( singleListThingyData, true)
	);
}