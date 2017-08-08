module smells::Size

import grammarlab::language::Grammar;
import IO;
import util::Math;
import List;
import GrammarInformation;
import Set;
import PowerMaloy;
import lang::json::IO;
import Violations;
import smells::Complexity;
import Relation;
import complexity::MCCabe;
import complexity::NestingDegree;
import complexity::OperationBased;
import Size;

data MetaSymbolUsage = 
	useStar() | usePlus() | useConj() | useOptional() | useDisj() | useEpsilon() | useSepListPlus() | useSepListStar() | useNot();


void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	sizeData = for(<l, gInfo,vs> <- triples) {
	
		rel[str,str] transitiveReferences = (gInfo.d.references+);
		list[map[str,value]] nonterminalInfos = [buildNonterminalInfo(gInfo, n, transitiveReferences) | n <- { lhs | production(lhs,_) <- gInfo.g.P}];
		
		append
			( "location" : "<l>"
			, "nonterminals": nonterminalInfos
			, "halstead": halsteadEffort(nonterminalInfos)
			, "levels" : [ size(partition) | partition <- gInfo.d@levels.partitions]
			, "impurity" : treeImpurity(gInfo)
			);
	}
	
	IO::writeFile(
		|project://grammarsmells/output/sizes.json|,
		toJSON( sizeData, true)
	);
}

//Power Maloy. Metric suite for grammar based software.
//Not reflexive, asymmetric.
real treeImpurity(GrammarInfo gInfo) {
	int n = size(domain(gInfo.d.references) + range(gInfo.d.references) + toSet(gInfo.g.N));
	int e = size({ {a,b} | <a,b> <- gInfo.d.references+, a != b });
	return impurityValue(n,e);
}

real impurityValue(0, _) = 0.0;
real impurityValue(1, _) = 0.0;
real impurityValue(2, _) = 0.0;
real impurityValue(int n, int e) =
	(n - e > 1) ? 0.0 : ((2.0 * (e - n + 1)) / ((n*1.0 - 1)*(n*1.0 - 2)))* 100.0;
	
	

map[str,value] buildNonterminalInfo(GrammarInfo gInfo, str n, rel[str,str] transitiveReferences) {
	list[GProd] prods =  gInfo.d.nprods[n]? ? gInfo.d.nprods[n] : [];
	
	list[map[str,value]] productionInfos = [ buildProductionInfo(p) | p <- prods];
	return 
		( "prods" : productionInfos
		, "nonterminal": n
		, "recursive" : (<n,n> in gInfo.d.references)
		, "mutualRecursive" : (<n,n> in transitiveReferences) 
		);
}

map[str,value] buildProductionInfo(p:production(lhs,rhs)) {
	int nonterminals = 0;
	list[str] ns = [];
	
	int terminals = 0;
	list[str] ts = [];
	
	int metasymbols = 0;
	list[MetaSymbolUsage] metasymbolUsages = [];
	
	int cc = complexity::MCCabe::compute(p.rhs);
	int noPreterminals = 0;
	list[GValue] pts = [];
	
	visit(rhs) {
		case terminal(t): {
			terminals = terminals + 1;
			ts = ts + t;
		}
		case nonterminal(x): { 
			nonterminals = nonterminals + 1;
			ns = ns + x;
		}
		case val(x): {
			noPreterminals = noPreterminals + 1;
			pts = pts + x;
		}
		case mark(_,_): {};
		case label(_,_): {};
		case anything(): {}; //TODO Is this a metasymbol?
		case epsilon(): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useEpsilon();
		}
		case empty(): {};
		case sequence(xs): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + [ useConj() | _ <- [1..size(xs)] ];
		}
		case choice(xs): {
			metasymbols = metasymbols + 1; 
			metasymbolUsages = metasymbolUsages + [ useDisj() | _ <- [1..size(xs)] ];
		}
		case optional(_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useOptional();
		}
		case plus(_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + usePlus();
		}
		case star(_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useStar();
		}
		case seplistplus(_,_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useSepListPlus();
		}
		case sepliststar(_,_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useSepListStar();
		}
		case not(_): {
			metasymbols = metasymbols + 1;
			metasymbolUsages = metasymbolUsages + useNot();
		}
		case GExpr a : {
			println("SIZE-TODO: <a>");
		}
	}
	return 
		( "nonterminals": ("total": nonterminals, "items" : ns)
		, "terminals" : ("total": terminals, "items": ts)
		, "preterminals": ("total": noPreterminals, "items": ["<pt>" | pt <- pts])
		, "metasymbols": ("total": metasymbols, "items" : [ "<ms>" | ms <- metasymbolUsages])
		, "complexity":
			( "cc" : complexity::MCCabe::compute(p.rhs)
			, "nesting" : complexity::NestingDegree::compute(p.rhs)
			, "nestingAndCC" : complexity::OperationBased::compute(p.rhs)
			)
		,  "size" : Size::expressionSize(rhs)
		);
}


int halsteadEffort(list[map[str,value]] nonterminalInfos) {
	int operators = size({ metaSymbol 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] metaSymbols := pInfo["metasymbols"]
		, list[str] metaSymbolItems := metaSymbols["items"]
		, metaSymbol <- metaSymbolItems});
		
	int occurencesOperators =
		size([0] + 
		[ size(metaSymbolItems)
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] metaSymbols := pInfo["metasymbols"]
		, list[str] metaSymbolItems := metaSymbols["items"]
		]);
		
	int terminalOperands = size({ terminal 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] terminals := pInfo["terminals"]
		, list[str] terminalItems := terminals["items"]
		, terminal <- terminalItems});
		
	int occurenceTerminalOperands = sum([0]+[ size(terminalItems) 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] terminals := pInfo["terminals"]
		, list[str] terminalItems := terminals["items"]
		, terminal <- terminalItems]);
		
	int preterminalOperands = size({ preterminal 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] preterminals := pInfo["preterminals"]
		, list[str] preterminalItems := preterminals["items"]
		, preterminal <- preterminalItems});
	
	int occurencePreterminalOperands = sum([0]+
		[ size(preterminalItems) 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] preterminals := pInfo["preterminals"]
		, list[str] preterminalItems := preterminals["items"]
		]);
			
	int nonterminalOperands = size({ nonterminal 
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] nonterminals := pInfo["nonterminals"]
		, list[str] nonterminalItems := nonterminals["items"]
		, nonterminal <- nonterminalItems});
	
	int occurenceNonterminalOperands = sum([0] +
		[ size(nonterminalItems)  
		| map[str,value] nonterminalInfo <- nonterminalInfos
		, list[map[str,value]] prodInfos := nonterminalInfo["prods"]
		, map[str,value] pInfo <- prodInfos
		, map[str,value] nonterminals := pInfo["nonterminals"]
		, list[str] nonterminalItems := nonterminals["items"]
		, nonterminal <- nonterminalItems
		]);
	
	int operands = terminalOperands + preterminalOperands + nonterminalOperands;
	int occurencesOperands =  occurenceTerminalOperands + occurencePreterminalOperands + occurenceNonterminalOperands;
	return 
		round(
			(operators * operands * ( occurencesOperators + occurencesOperands) * log2(operators + operands))
			/ (2 * operands)
		);
}
