module smells::TravelingFamily


import Violations;
import GrammarInformation;
import grammarlab::language::Grammar;

import Set;
import List;
import IO;
import lang::json::IO;

void export(list[tuple[loc, GrammarInfo, set[Violation]]] triples) {
	list[value] travelingFamily  =
		[ ( "location" : "<l>"
		  , "violations" :
	  			[ distantElementJson(d)
				| <violatingProductions(_), distantElements(d)> <- vs
	  			]
		  )
		| <l,g,vs> <- triples
		];
	
	IO::writeFile(
		|project://grammarsmells/output/traveling-family.json|,
		toJSON(travelingFamily, true)
	);	
}

value distantElementJson(DistantElement e) {
	switch(e) {
		case scatteredLevel(l, v, other): 
			return
				( "level" : toList(l)
				, "type" : "scattered-level"
				, "productions" :
						[ [i, p.lhs]
						| <i,p> <- v
						]
				);
		case mixedInLevel(l, v, other):
			return 
				( "level" : toList(l)
				, "type" : "mixed-in-level"
				, "productions" :
						[ [i, p.lhs]
						| <i,p> <- v
						]
				);
	}
}



set[Violation] violations(gInfo:grammarInfo(g:grammar(ns,_,_), grammarData(refs, nprods, expressionIndex, tops, _), _)) {	
	languageLevels(parts, partsRel) = gInfo.d@levels;
	rel[str, str] refsStar = gInfo.d.references*;
	
	result = for(part <- parts, size(part) > 1) {
		str elem  = getOneFrom(part);
		
		int spanOffset = size(takeWhile(gInfo.g.P, (bool)(GProd e) { return e.lhs notin part;} ));
		list[GProd] span = getSpanForLevel(part, gInfo.g.P);		
		set[str] reach = refsStar[elem];
		
		list[GProd] violations = [ x | x <- span, x.lhs notin reach && elem notin refsStar[x.lhs]];
		if (size(violations) > 0) {
			if (size(part) < size(violations)) {
				append < violatingProductions( { x | x <- span, x.lhs in part } )
				       , distantElements
							( scatteredLevel
								( part
								, [ <spanOffset + i,x> | <x,i> <- zip(span, index(span)), x.lhs in part ]
								, [ <i,p> | <p,i> <- zip(gInfo.g.P, index(gInfo.g.P)), p in violations ]
								)
							)
					   >;
			} else { 
				append < violatingProductions( toSet(violations) )
				       , distantElements
							( mixedInLevel
								( part
								, [ <i, p> | <p,i> <- zip(gInfo.g.P, index(gInfo.g.P)), p in violations ]
								, [ <i + spanOffset, x> | <x,i> <- zip(span, index(span)), x.lhs in part ]
								)
							)
					   >;
			}
		}
	}
	return toSet(result);
}

list[GProd] getSpanForLevel(set[str] part, list[GProd] P) =
	reverse(dropAllNotIn(part, reverse(dropAllNotIn(part, P))));


list[GProd] dropAllNotIn(set[str] part, list[GProd] a) {
	int x = size(takeWhile(a, (bool)(GProd n) { return n.lhs notin part;} ));
	return drop(x, a);
}

test bool testDropAllNotIn1() = dropAllNotIn({"a","b"}, input1) == drop(1, input1);
list[GProd] input1 = [production("c", epsilon()), production("a", epsilon())];

test bool testDropAllNotIn2() = dropAllNotIn({"a","b"}, input2) == drop(0, input2);
list[GProd] input2 = [production("b",epsilon()), production("c", epsilon()), production("a", epsilon())];


