module smells::MixedDefinitions


import grammarlab::language::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import List;
import GrammarInformation;
import Violations;
import lang::json::IO;
import grammarlab::export::Grammar;

data DefinitionDirection
	= horizontal(str s)
	| vertical(str s)
	| zigZag(str s)	
	| undecided(str s)
	;

void analysis(list[tuple[loc, GrammarInfo,set[Violation]]] triples) {
	println();
	for (<l,gInfo,vs> <- triples
		// Uncomment if only files with a single violation should be analysed
		, size([ z | <violatingNonterminal(z),mixedDefinition()> <- vs]) <= 2
		, <violatingNonterminal(y),mixedDefinition()> <- vs) {
		println("---------------");
		prods = [ p | p <- gInfo.g.P, p.lhs == y];
		println("REASON <buildReason(prods)>");
		println(l);

		for(p <- prods) {
			print(ppx(p));
		} 
		//println("<l> - <y>");
		println();
	}
}

str buildReason(list[GProd] ps) {
	if (inIsCompositeOfOthers(ps)) {
		return "inIsCompositeOfOthers";
	}
	if (isOrAndEpsilon(ps)) {
		return "isOrAndEpsilon";
	}
	if (overlappingOptions(ps)) {
		return "overlappingOptions";
	}
	//TODO disjointOptions mose specific
	return "disjointOptions";
	 
}

bool inIsCompositeOfOthers(list[GProd] ps) {
	list[GProd] choiceProds = [ p | p:production(_,choice(_)) <- ps];
	if (size(choiceProds ) == 1) {
		production(_,choice(xs)) = getOneFrom(choiceProds);
		result = (xs | it - e | production(_,e) <- (ps - choiceProds)); 
		return result == [];
	} 
	return false;
}

bool overlappingOptions(list[GProd] ps) {
	options = ( [] | it + optionsOfExpr(p.rhs) | p <- ps);
	if (size(toSet(options)) != size(options)) {
		dups = options - toList(toSet(options));
		return any(d <- dups, !containsVal(d) || d == epsilon());
	} 
	return false;
}

bool containsVal(GExpr e) = /val(_) := e; 

list[GExpr] optionsOfExpr(choice(xs)) = ( [] | it + optionsOfExpr(x) | x <- xs);
list[GExpr] optionsOfExpr(GExpr e) = [e];


bool isOrAndEpsilon(list[GProd] ps) {
	if ([x,y] := ps) {
		return {epsilon(), choice(_)} := {x.rhs, y.rhs};
	} 
	return false;
}
set[Violation] violations(GrammarInfo info) =
	{ <violatingNonterminal(y),mixedDefinition()> | x <- definitionStyles(info), zigZag(y) := x};

set[DefinitionDirection] definitionStyles(grammarInfo(grammar(ns,_,_), grammarData(_, nprods, _,_,_), _)) {
	set[str] horizontals = { k | k <- nprods, anyHorizontal(nprods[k])};
	set[str] verticals = { k | k <- nprods, size(nprods[k]) > 1};
	set [str] zigZags = (verticals & horizontals);
	
	return { zigZag(s) | s <- zigZags }
		 + { horizontal(s) | s <- (horizontals - zigZags)}
		 + { vertical(s) | s <- (verticals - zigZags)}
		 + { undecided(s) | s <- (ns - horizontals - verticals) }
		 ;
}


bool anyHorizontal(list[GProd] items) =
	any(i <- items, horizontal(i));

bool horizontal(production(lhs, rhs)) =
	choice(xs) := rhs;
	

void writeMixedDefinitionStats(list[tuple[loc, GrammarInfo,set[Violation]]] input) {
	lrel[loc,set[DefinitionDirection]] definitionStyleList = 
		[ <l, definitionStyles(gInfo)>
		| <l, gInfo, vs> <- input
		];
		
	list[value] x = [ mixedDefinitonJson(l, defs) | <l, defs> <- definitionStyleList];
	lrel[bool,bool,bool] triples = [ <(/horizontal(_) := ds), (/vertical(_) := ds), (/zigZag(_) := ds)> | <_,ds> <- definitionStyleList ];
	
	map[tuple[bool,bool,bool],int] m = ( <a,b,c> : 0 | a <- {true,false}, b <- {true,false}, c <- {true,false} );
	m = ( m | incK(it,k, 1) | k <- triples);
	map[str,int] totals = ( directionTotals({}) | merge(it, directionTotals(v), (int)(int a, int b){return a + b;} ) | <_,v> <- definitionStyleList);
	
	overall = ( "file_types" : ( key : m[<a,b,c>] | <a,b,c> <- m,  key := (a ? "h" : "")+(b ? "v" : "") + (c ? "z" : ""))
			  , "totals" : totals 
			  );
			  
	IO::writeFile(
		|project://grammarsmells/output/mixed-definitions.json|,
		toJSON( ( "files" : x, "overall" : overall), true)
	);	
}

value mixedDefinitonJson(loc l, set[DefinitionDirection] x) {
	map[str, value] r = directionTotals(x);
	r["location"] = "<l>";
	r["group"] = groupForDefinitionDirection(x);
	return r;
}

str groupForDefinitionDirection(set[DefinitionDirection] x) {
	bool h= any(horizontal(_) <- x);
	bool v = any(vertical(_) <- x);
	bool z = any(zigZag(_) <- x);
	return (h ? "h" : "")+(v ? "v" : "") + (z ? "z" : "");
}


map[str, int] directionTotals(set[DefinitionDirection] x) =
	( "horizontals" : size({ v | v:horizontal(_) <- x})
	, "verticals" : size({ v | v:vertical(_) <- x})
	, "zigzags" : size({ v | v:zigZag(_) <- x})
	, "undecided" : size({ v | v:undecided(_) <- x})
	);
	