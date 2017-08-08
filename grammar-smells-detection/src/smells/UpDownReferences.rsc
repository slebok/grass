module smells::UpDownReferences

import grammarlab::language::Grammar;
import GrammarUtils;
import List;
import Set;
import IO;
import util::Math;
import Violations;
import GrammarInformation;
import Relation;
import ListRelation;
import grammarlab::export::Grammar;
import smells::ReferenceDistance;
import lang::json::IO;

data ReferenceInfo =
 referenceInfo(int up, int down, ReferenceDir dir, real ratio);

alias ProdReferences = tuple[GProd p, int up, int down];

data ReferenceDir
	= upReferencing()
	| downReferencing()
	| evenReferencing()
	;
	
tuple[int,int] addReferences(<xUp, xDown> , <_, yUp, yDown>) =
	 <xUp + yUp, xDown + yDown>;

set[Violation] violations(info:grammarInfo(g:grammar(_, ps, _), gd:grammarData(refs, nprods, expressionIndex, tops, _), _)) {
	ReferenceInfo prodR = getReferenceInfo(info);
	referenceInfo(up,down ,dir,ratio) = prodR;
	int(int) f = (dir == upReferencing()) ? (int(int x) { return -x; }) : (int(int x) { return x * 1; });
	
	rel[str,str] r = refs+;
	
	languageLevels(levels, levelRelations) = gd@levels;
	set[set[str]] nonSingletonLevels ={ l | l <- levels, size(l) > 1};
	levelRelationsPlus = levelRelations+;
	map[GProd,int] prodIndex = ( k : v | <k,v> <- zip(ps,List::index(ps)));
	
	list[rel[set[str],str]] violatingNs;
	violatingNs = for (nonSingletonLevel <- nonSingletonLevels) {
		allowed = nonSingletonLevel + union(levelRelationsPlus[nonSingletonLevel]);
		set[int] indexes = { prodIndex[prod] | n <- nonSingletonLevel, prod <- nprods[n] };
		int first = min(indexes);
		int last = max(indexes);
		list[GProd] window = take(last + 1 - first, drop(first, ps));
		append { <nonSingletonLevel, w.lhs> | w <- window, w.lhs notin allowed };
	}
	
	return 
		{ < violatingNonterminal(n)
		  , misplacedNonterminal(level, n)		 
		  > 
		| <level, n> <- union(toSet(violatingNs)) };
}

GrammarInfo optimize(gInfo, bool optimizeRefDistance) {
	int refDistanceBefore = referenceDistances(gInfo)[1];
	ReferenceInfo refInfoBefore = getReferenceInfo(gInfo);
	bool shouldReverse = refInfoBefore.dir == upReferencing();
	list[GProd] ps = shouldReverse ? reverse(gInfo.g.P) : gInfo.g.P;
	languageLevels(partitions, partitionsRel) = gInfo.d@levels;
	
	rel[set[str],set[set[str]]] referedBy = { <l,refLs> | l <- partitions, xs := { x | <x,y> <- gInfo.d.references, y in l}, refLs := { k | k <- partitions,  k & xs != {}}  };
	rel[set[str],set[str]] referedByOne = { <x,y> | <x,{y}> <-  referedBy};
	
	newPs = sortLevels(partitions, partitionsRel, ps, gInfo.d, invert(referedByOne));
	
	newPs = optimizeRefDistance ? bubbleUpLevels(gInfo, partitions, partitionsRel, newPs) : newPs;
	
	gInfo.g.P = shouldReverse ? reverse(newPs) : newPs;
	ReferenceInfo refInfoAfter = getReferenceInfo(gInfo);
	
	int refDistanceAfter = referenceDistances(gInfo)[1];
	
	println("Ref distance: <refDistanceBefore> -\> <refDistanceAfter>");
	println("Ref info before <refInfoBefore>");
	println("Ref info after <refInfoAfter>");
	println();
	
	//println(grammarlab::export::Grammar::ppx(gInfo.g));
	return gInfo;
}

list[GProd] bubbleUpLevels(GrammarInfo gInfo, set[set[str]] partitions, rel[set[str],set[str]] partitionRel, list[GProd] ps) {
	ordered = orderPartitionsByProds(partitions, ps);
	return (ps | moveLevelUp(it, gInfo, level, limitsForLevel(level, partitionRel)) | level <- ordered); 
}

set[str] limitsForLevel(set[str] level, rel[set[str],set[str]] partitionRel) =
	union(invert(partitionRel)[level]);


list[GProd] moveLevelUp(list[GProd] ps, GrammarInfo gInfo, set[str] level, set[str] limits) {
	set[int] indexes = { i | <p,i> <- zip(ps, index(ps)), p.lhs in level};
	if (min(indexes) == 0) {
		return ps;
	}
	if (ps[min(indexes) - 1].lhs in limits) {
		return ps;
	}
	gInfoBefore = gInfo.g.P = ps;
	int refDistanceBefore = referenceDistances(gInfoBefore)[1];
	
	newPs = moveWindowUp(min(indexes), max(indexes), ps);
	gInfoAfter = gInfo.g.P = newPs;
	int refDistanceAfter = referenceDistances(gInfoAfter)[1];
	
	if(refDistanceAfter < refDistanceBefore) {
		return moveLevelUp(newPs, gInfo, level, limits);
	} else {
		return ps;
	}
	
	
}

list[&T] moveWindowUp(int from, int to, list[&T] target) {
	toMove = target[from..(to+1)];
	newHead = target[0..(from-1)];
	newTail = target[from-1] + target[(to+1)..];
	return newHead + toMove + newTail;
}


list[set[str]] orderPartitionsByProds(set[set[str]] partitions, list[GProd] prods) {
	list[set[str]] byOccurence = dup([ part | p <- prods, part <- partitions, p.lhs in part]);
	return byOccurence;
}


list[GProd] sortLevels(set[set[str]] partitions, rel[set[str],set[str]] partitionRel, list[GProd] ps, GrammarData d, rel[set[str],set[str]] referedOnce) {
	reducedPartitionsRel = partitionRel;
	reducedPartitions = partitions;
	list[GProd] answer = [];
	
	map[GProd,int] prodIndex = ( p : i | <p,i> <- zip(ps, index(ps)));
	
	while(true) {
		set[set[str]] nextCandidates = domain(reducedPartitionsRel) - range(reducedPartitionsRel);
		if (nextCandidates == {}) {
			break;
		}
		list[tuple[set[str],int]] candidatePairs = [ <nextCandidate, firstIndex> | nextCandidate <- nextCandidates, int firstIndex := min([ prodIndex[p] | n <- nextCandidate, p <- d.nprods[n]]) ];
		list[tuple[set[str],int]] sortedPairs = sort(candidatePairs, (bool)(tuple[set[str],int] a, tuple[set[str],int] b) { return a[1] < b[1]; });
		
		set[str] nextLevelItem = sortedPairs[0][0];
		
		<addToAnswer,toRemove> = nextProds(nextCandidates, ps, d, referedOnce, prodIndex);
		answer = answer + addToAnswer;
		reducedPartitions = reducedPartitions - toRemove;
		reducedPartitionsRel = { <a,b> | <a,b> <- reducedPartitionsRel, a notin toRemove};
	}
	
	return ( answer | it + orderedProsForNs(toList(part), ps, d, prodIndex) | part <- reducedPartitions);
}

tuple[list[GProd], set[set[str]]] nextProds(set[set[str]] nextCandidates, list[GProd] ps, GrammarData d, rel[set[str],set[str]] referedOnce, map[GProd,int] prodIndex) {
	if (nextCandidates == {}) {
		return <[],{}>;
	}
	list[tuple[set[str],int]] candidatePairs =
		[ <nextCandidate, firstIndex>
		| nextCandidate <- nextCandidates
		, is := [ prodIndex[p] | n <- nextCandidate, d.nprods[n]?, p <- d.nprods[n]]
		, is != []
		, int firstIndex := min(is)
		];
	if (candidatePairs == []) {
		return <[],{}>;
	}
	list[tuple[set[str],int]] sortedPairs = sort(candidatePairs, (bool)(tuple[set[str],int] a, tuple[set[str],int] b) { return a[1] < b[1]; });
	set[str] nextLevelItem = sortedPairs[0][0];
	
	list[str] orderedNs =
		domain(sort
			( [ <n, min([ prodIndex[p] | p <- d.nprods[n]])> | n <- nextLevelItem ]
			, (bool)(tuple[str,int] a, tuple[str,int] b) { return a[1] < b[1]; }
			));

	list[GProd] answer = orderedProsForNs(orderedNs, ps, d, prodIndex);
	set[str] used = toSet(orderedNs);	
	
	set[set[str]] inlineables = referedOnce[toSet(orderedNs)];
	
	<answerAfter, otherUsed> = nextProds(inlineables - {used}, ps, d, referedOnce, prodIndex);
	
	return <answer + answerAfter,{used} + otherUsed>;
}

list[GProd] orderedProsForNs(list[str] ns, list[GProd] ps, GrammarData d, map[GProd,int] prodIndex) =
	( []
	| it + sort(d.nprods[n], (bool)(GProd a, GProd b) { return prodIndex[a] < prodIndex[b]; })
	| n <- ns 
	, d.nprods[n]?
	);
	
set[str] levelFor(set[str] items, set[set[str]] levels) = 
	getOneFrom({ level | level <- levels, items <= level })
	; 


list[list[GProd]] groupProductionsByLevel(list[GProd] prods, set[set[str]] levels) {
	list[list[GProd]] result = [];
	list[GProd] next = take(1, prods);
	list[GProd] rest = drop(1, prods);
	
	for (p <- rest) {
		production(lastLhs, _) = last(next);
		production(lhs,rhs) = p;
		if (size({ level | level <- levels, lhs in level && lastLhs in level }) == 0) {
			result += [next];
	 		next = [p];
		} else {
			next += [p];
		}
	}
	result += [next];
	return result;
}

int MOVE_DISTANCE = 5;

bool canMutateToReduceRatio(info:grammarInfo(grammar(_, ps, _), grammarData(_, _, expressionIndex, tops, _), _), ReferenceInfo currentReferenceInfo, GProd prod) {
	int current = indexOf(ps, prod);
	list[list[GProd]] perms =  movesOfElementInDistance(ps, current, MOVE_DISTANCE);
	return any(perm <- perms, isMoreExtreme(getReferenceInfo(info), currentReferenceInfo)); 
}

bool isMoreExtreme(referenceInfo(_, _, _, aRatio), referenceInfo(_ ,_ ,_ , bRatio)) =
	aRatio > bRatio;

list[list[&T]] movesOfElementInDistance(list[&T] input, int index, int distance) {
	list[int] positions = insertPositions(index, size(input), distance);
	return [ List::insertAt( List::delete(input, index), p, input[index]) | p <- positions ];  
}
list[int] insertPositions(int current, int length, int distance) {	
	return [x | x <- [(current-distance)..(current + distance + 1)], x != current, x >= 0, x <= length ];
} 

ReferenceInfo getReferenceInfo(grammarInfo(g:grammar(_, ps, _), grammarData(_, nprods, expressionIndex, tops, _), _)) {
	list[GProd] prods = ps; 
	map[GProd, int] pIndexes = ( q : i | <q,i> <- zip(prods, index(prods)));
	
	<up,down> = ( <0,0> | addReferences(it, prodReference(nprods, pIndexes, g,p)) | p <- ps);
	int diff = abs(up - down);
	real ratio = diff == 0 ? 0.0 : (diff / 1.0) / (up + down);
	return 
		referenceInfo(
			  up
			, down
			, up == down ? evenReferencing() : (up < down ? downReferencing() : upReferencing())
			, ratio
		);
} 

ProdReferences prodReference(map[str, list[GProd]] nprods, map[GProd, int] pIndexes, GGrammar theGrammar:grammar(_,ps,_), GProd p) {
	production(lhs, rhs) = p;
	 
	set[str] ns = exprNonterminals(rhs);
	int pIndex = pIndexes[p];
	int down = 0;
	int up = 0;

	for(n <- ns) {
		otherPIndices = {pIndexes[otherP] | nprods[n]?, otherP <- nprods[n]};
		if ( !isEmpty({ i | i <- otherPIndices, pIndex < i})) {
			down +=1;
		} 
		if ( !isEmpty({ i | i <- otherPIndices, pIndex > i})) {
			up +=1;
		} 
	}  
	return <p, up, down>;
}


//Export
void export(list[tuple[loc, GrammarInfo, set[Violation]]] input) {
	exportTo(|project://grammarsmells/output/reference-info.json|, input);
}

void exportOptimized(list[tuple[loc, GrammarInfo, set[Violation]]] input) {
	exportTo(|project://grammarsmells/output/reference-info-optimized.json|, input);
}

void exportTo(loc target, list[tuple[loc, GrammarInfo, set[Violation]]] input) {
	x = for (<l,gInfo,vs> <- input) {
		ReferenceInfo refInfo = getReferenceInfo(gInfo);
		map[str,value] j = referenceInfoJson(l, refInfo);
		j["violations"] = toList({ n | v:<violatingNonterminal(n),misplacedNonterminal(level, n)> <- vs});
		append j;
	}
	IO::writeFile(target, toJSON(x, true));
}

value totalStats(lrel[loc,ReferenceInfo] referenceInfos) {
	int downs = size([ i | <a, i> <- referenceInfos, referenceInfo(_,_,downReferencing(),_) := i ]);
	int ups = size([ i | <a, i> <- referenceInfos, referenceInfo(_,_,upReferencing(),_) := i ]);
	int evens = size([ i | <a, i> <- referenceInfos, referenceInfo(_,_,evenReferencing(),_) := i ]); 
	return
		( "downs": downs
		, "ups" : ups
		, "evens": evens
		);
} 

map[str,value] referenceInfoJson(loc l, ReferenceInfo i:referenceInfo(up,down,dir,ratio)) =
	( "location" : "<l>"
	, "up" : up
	, "down" : down
	, "dir" : dir == downReferencing() ? "DOWN" : dir == upReferencing() ? "UP" : "EVEN"
	, "ratio" : ratio
	);
	
