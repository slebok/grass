module smells::ReferenceDistance

import grammarlab::language::Grammar;
import GrammarUtils;
import List;
import Set;
import util::Math;
import IO;
import Violations;
import lang::json::IO;
import GrammarInformation;

alias ReferenceDistanceInfo = 
	tuple[lrel[GProd,int],int]
	;


void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	psData = for (<l, gInfo, vs > <- triples) {
		map[GProd, int] pIndex = ( p : i | <p,i> <- zip(gInfo.g.P, index(gInfo.g.P)));
		psData = 
			[ ( "min" : referenceDistanceMin(gInfo.g, p, gInfo.d.references, gInfo.d.nprods,pIndex)
			  , "avg" : referenceDistanceAvg(gInfo.g, p, gInfo.d.references, gInfo.d.nprods,pIndex)
			  , "max" : referenceDistanceMax(gInfo.g, p, gInfo.d.references, gInfo.d.nprods,pIndex)
			  , "lhs" : p.lhs
			  , "index" : i
			  )
			| <p,i> <- zip(gInfo.g.P, index(gInfo.g.P))
			];
		append 
			( "location": "<l>"
			, "violations": [ [ p.lhs, indexOf(gInfo.g.P, p), p1.lhs, p2.lhs, p3.lhs] | v <- vs , <violatingProduction(p),referenceDistanceJumpOver(p1, p2, p3)> := v]
			, "prods" :psData
			);
	}
	
	IO::writeFile(
		|project://grammarsmells/output/reference-distance-data.json|,
		toJSON( psData, true)
	);
	
}

//TODO Test on |project://grammarsmells/input/zoo/automata/petri/pnml/standard/terms/extracted/grammar.bgf| (first, second and third) `Declaration.content`.

set[Violation] violations(grammarInfo(g:grammar(_,ps,_), grammarData(r, _, expressionIndex, tops, _), _)) {
	list[str] l = orderedLhs(g);
	rel[str,str] rPlus = r+;
	return 
		{ <violatingProduction(bp)
		  , referenceDistanceJumpOver(ap,bp,cp)
		  >
		| [_*,ap:production(a,_),bp:production(b,_),cp:production(c,_),_*] := ps
		, jumpsOver(a,b,c, rPlus)
		};
}

ReferenceDistanceInfo referenceDistances(grammarInfo(g:grammar(_,ps,ss), grammarData(r, nprods, _, _, _), _)) {
	map[GProd, int] pIndex = ( p : i | <p,i> <- zip(ps, index(ps)));
	pairs = [ <p, referenceDistanceMax(g, p, r, nprods, pIndex)> | p <- ps];
	int total =  sum([0] + [ x | <_,x> <- pairs]);
	return <pairs,total>;
}

int referenceDistanceMax( GGrammar theGrammar:grammar(_,ps,_)
					 , GProd prod:production(lhs,rhs)
					 , rel[str,str] references
					 , map[str, list[GProd]] nprods
					 , map[GProd, int] pIndex) {
	return referenceDistanceWithF(theGrammar, prod, references, nprods, pIndex, (int)(list[int] x) { return x == [] ? 0 : List::max(x); });
}

int referenceDistanceMin( GGrammar theGrammar:grammar(_,ps,_)
					 , GProd prod:production(lhs,rhs)
					 , rel[str,str] references
					 , map[str, list[GProd]] nprods
					 , map[GProd, int] pIndex) {
	return referenceDistanceWithF(theGrammar, prod, references, nprods, pIndex, (int)(list[int] x) { return x == [] ? 0 : List::min(x); });
}


int referenceDistanceAvg( GGrammar theGrammar:grammar(_,ps,_)
					 , GProd prod:production(lhs,rhs)
					 , rel[str,str] references
					 , map[str, list[GProd]] nprods
					 , map[GProd, int] pIndex) {
	return referenceDistanceWithF(theGrammar, prod, references, nprods, pIndex, (int)(list[int] x) { return x == [] ? 0 : round(List::sum(x) / 1.0 / size(x)); });
}


int referenceDistanceWithF( GGrammar theGrammar:grammar(_,ps,_)
					 , GProd prod:production(lhs,rhs)
					 , rel[str,str] references
					 , map[str, list[GProd]] nprods
					 , map[GProd, int] pIndex
					 , (int)(list[int]) f) {
	set[str] ns = references[lhs];
	int rhsIndex = pIndex[prod];
	items = [  f([ abs(rhsIndex - pIndex[p])  | nprods[n]?, p <- nprods[n] ]) | n <- ns ];
	return sum([0] + items);
}


bool jumpsOver(str a, str b, str c, rel[str,str] r) =
	(<a,c> in r && <a,b> notin r) || (<c,a> in r && <c,b> notin r);



