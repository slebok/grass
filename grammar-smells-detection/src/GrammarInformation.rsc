module GrammarInformation

import grammarlab::io::read::BGF;
import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Partitions;
import List;
import Relation;

alias ExpressionIndex = map[ExpressionOccurence, list[ExpressionOccurenceLocation]];
alias Facts = map[FactProperty, bool];

data GrammarData
	= grammarData(
		rel[str,str] references,
		map[str, list[GProd]] nprods,
		ExpressionIndex exprIndex,
		set[str] tops,
		set[str] bottoms
	  );
	  
anno rel[str,str] GrammarData @ references;

data FactProperty 
	= containsStar()
	| containsPlus()
	| containsOptional()
	| containsChoice()
	| containsSequence()
	| containsEpsilon()
	;
	
data GrammarInfo
	= grammarInfo(
		GGrammar g,
		GrammarData d,
		Facts facts
	  );

anno LanguageLevels GrammarData @ levels;


bool containsStarFact(grammarData(_,_,index,_,_))
	= any( k <- index
		 , fullExpr(star(_)) := k
		 );

bool containsPlusFact(grammarData(_,_,index,_,_)) 
	= any( k <- index
		 , fullExpr(plus(_)) := k
		 );

bool containsOptionalFact(grammarData(_,_,index,_,_))
	= any( k <- index
		 , fullExpr(optional(_)) := k
		 );
		 
bool containsChoiceFact(grammarData(_,_,index,_,_))
	= any( k <- index
		 , fullExpr(choice(_)) := k 		 
		 );

bool containsSequenceFact(grammarData(_,_,index,_,_))
	= any( k <- index
		 , fullExpr(sequence(_)) := k
		 );
		 
bool containsEpsilonFact(grammarData(_,_,index,_,_))
	= any( k <- index
		 , fullExpr(epsilon()) := k
		 );
	

data LanguageLevels =
	languageLevels(set[set[str]] partitions, rel[set[str],set[str]] partitionRel);


GGrammar postProcess(GGrammar g) {
	return visit (g) {
		case label(_,expr) => expr
		case mark(_,expr) => expr
	};
	//return g;
}

GrammarInfo buildFromGrammar(GGrammar theGrammar) {

	theGrammar = postProcess(theGrammar);
		
	map[str, list[GProd]] nprods = nonterminalProdMap(theGrammar);
	rel[str,str] refs = nonterminalReferencesWithProdMap(theGrammar, nprods);
	set[set[str]] partitions = Partitions::partitionForTransitiveClosure(toSet(theGrammar.N) + domain(refs) + range(refs), refs);
	rel[set[str],set[str]] partitionRel = { <x,y> | x <- partitions, y <- partitions, x != y, any(m <- x, n <- y, <m,n> in refs)};
	
	LanguageLevels ll = languageLevels(partitions, partitionRel);
	//iprintln(ll);
	GrammarData d = grammarData(
		refs,
		nprods,
		buildExpressionIndex(theGrammar),
		grammarTops(theGrammar, refs),
		grammarBottoms(theGrammar, refs)
	);
	
	d@levels = ll;
	
	facts =
	    ( containsStar() : containsStarFact(d)
		, containsPlus() : containsPlusFact(d)
		, containsOptional() : containsOptionalFact(d)
		, containsChoice() : containsChoiceFact(d)
		, containsSequence() : containsSequenceFact(d)
		, containsEpsilon() : containsEpsilonFact(d)
		);
	return grammarInfo(
		theGrammar,
		d,
		facts
	);
}

GrammarInfo build(loc l) {
	GGrammar theGrammar = grammarlab::io::read::BGF::readBGF(l);
	return buildFromGrammar(theGrammar);
}


rel[str,str] references(grammarData(r,_,_,_,_)) =
	r;
