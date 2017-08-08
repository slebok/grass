module smells::LegacyStructures

import GrammarInformation;
import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import List;
import Violations;
import lang::json::IO;
	
	
set[Violation] violations(GrammarInfo info) =
	  { <violatingNonterminal(n), legacyUsage(legacyOptional(n))>
	  | n <- legacyOptionalViolations(info)
	  } 
	+ { <violatingNonterminal(n), legacyUsage(legacyPlus(n))>
	  | n <- legacyIterationPlusViolations(info)
	  }
    + { <violatingNonterminal(n), legacyUsage(legacyStar(n))>
	  | n <- legacyIterationStarViolations(info)
	  }
	  ;
	  
	  
void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	value legacyStructureData = [];
	legacyStructureData = for (<l, gInfo, vs > <- triples) {
		append 
			( "location": "<l>"
			, "plus" : [ n | <violatingNonterminal(n), legacyUsage(legacyPlus(n))> <- vs]
			, "star" : [ n | <violatingNonterminal(n), legacyUsage(legacyStar(n))> <- vs]
			, "optional" : [ n | <violatingNonterminal(n), legacyUsage(legacyOptional(n))> <- vs] 
			);
	}
	
	IO::writeFile(
		|project://grammarsmells/output/legacy-structures-data.json|,
		toJSON( legacyStructureData, true)
	);
	
}
	  
set[str] legacyOptionalViolations(grammarInfo(g, gData, facts)) =
	facts[containsOptional()] ? legacyOptionals(g, gData) : {};
	
set[str] legacyIterationPlusViolations(grammarInfo(g, gData, facts)) =
	facts[containsPlus()] ? legacyPlusIterations(g, gData) : {};

set[str] legacyIterationStarViolations(grammarInfo(g, gData, facts)) =
	facts[containsStar()] ? legacyStarIterations(g, gData) : {};
	

set[str] legacyOptionals(g:grammar(ns,ps,ss), grammarData(_, nprods, expressionIndex,_,_)) =
	{ n
    | n <- ns
    , pns := nprods[n]
    , isChoiceEpsilonOption(pns) //[p:production(_,choice([_,epsilon()]))] := pns && p.rhs != choice([epsilon(),epsilon()])
      || [production(_,_), p:production(_,epsilon())] := pns
	};

bool isChoiceEpsilonOption([p:production(_,choice([_,epsilon()]))]) = p.rhs != choice([epsilon(),epsilon()]);
bool isChoiceEpsilonOption([p:production(_,choice([epsilon(),_]))]) = p.rhs != choice([epsilon(),epsilon()]);
bool isChoiceEpsilonOption(list[GProd] _) = false;	


set[str] legacyStarIterations(g:grammar(ns,ps,ss), grammarData(_, nprods, expressionIndex,_,_)) {
	return { n
		   | n <- ns
		   , pns := toSet(nprods[n])
		   ,     { production(_, choice([epsilon(), sequence([nonterminal(n), a, b*])]))} := pns
		      || { production(_, choice([sequence([nonterminal(n), a, b*]), epsilon()]))} := pns
		      || { production(_, sequence([nonterminal(n), a, b*]))
		    	 , production(_, epsilon())
		    	 } := pns
	    	  || { production(_, sequence([a, b*, nonterminal(n)]))
		    	 , production(_, epsilon())
		    	 } := pns
		   };
}

set[str] legacyPlusIterations(g:grammar(ns,ps,ss), grammarData(_, nprods, expressionIndex,_,_)) {
	return { n
		    | n <- ns
		    , pns := toSet(nprods[n])
		    ,    { production(_, choice([a, sequence([nonterminal(n), a])]))} := pns
		      || { production(_, choice([sequence([a, b*]), sequence([nonterminal(n), a, b*])]))} := pns
		      || { production(_, choice([a, sequence([a, nonterminal(n)])]))} := pns
		      || { production(_, choice([sequence([a, b*]), sequence([a, b*, nonterminal(n)])]))} := pns
		      || { production(_, choice([sequence([nonterminal(n), a]), a]))} := pns
		      || { production(_, choice([sequence([nonterminal(n), sequence([a, b*]) ]), sequence(a, b*)]))} := pns
		      || { production(_, choice([sequence([a, nonterminal(n)]), a]))} := pns
		      || { production(_, choice([sequence([a, b*, nonterminal(n)]), sequence([a, b*]) ]))} := pns
		      || { production(_, sequence([nonterminal(n), a]))
		    	 , production(_, a)
		    	 } := pns
	    	  || { production(_, sequence([nonterminal(n), a, b*]))
		    	 , production(_, sequence([a, b*]))
		    	 } := pns
	    	  || { production(_, sequence([a, nonterminal(n)]))
		    	 , production(_, a)
		    	 } := pns
	    	  || { production(_, sequence([a, b*, nonterminal(n)]))
		    	 , production(_, sequence([a, b*]))
		    	 } := pns
		    	 
			};
}
