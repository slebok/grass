module Main

import IO;
import grammarlab::io::read::BGF;
import List;
import Input;
import grammarlab::language::Grammar;
import GrammarUtils;
import Map;
import Set;
import Relation;
import util::Math;
import lang::json::IO;
import Relation;

import smells::DisconnectedNonterminalGraph;
import smells::ProxyNonterminals;
import smells::NamingConvention;
import smells::Duplication;
import smells::ImproperResponsibility;
import smells::MixedDefinitions;
import smells::LegacyStructures;
import smells::EntryPoint;
import smells::MixedTop;
import smells::ProxyNonterminals;
import smells::ReferenceDistance;
import smells::ScatteredNonterminalProductionRules;
import smells::SingleListThingy;
import smells::SmallAbstractions;
import smells::UpDownReferences;
import smells::Massagable;
import smells::MultiTops;
import smells::ExplicitAmbiguity;
import smells::Complexity;
import smells::TravelingFamily;

import grammarlab::export::Grammar;

import Violations;
import GrammarInformation;
import Map::Extra;
import smells::Size;
import DateTime;
import String;


alias GrammarAnalysis = tuple[loc l, GrammarInfo gInfo, set[Violation] violations];

void multiStarts() {
	list[loc] inputFiles = Input::extractedGrammarLocationsInDir(|project://grammarsmells/input/zoo|);
	for ( l <- inputFiles) {
		gInfo = GrammarInformation::build(l);
		if (size(gInfo.g.S) > 1) {
			println(l);
			println(gInfo.g.S);
		}
		
	}
}

lrel[loc, GrammarInfo, set[Violation]] getInputFiles() {
	list[loc] inputFiles = Input::extractedGrammarLocationsInDir(|project://grammarsmells/input/zoo|);
	
	println("Loading grammar info for locations");
	triples = for
		( l <- inputFiles
		, !contains("<l>", "%A7wip/")
		//, contains("<l>","doc/docbook/relaxng/extracted/")
		) {
		println("Loading <l>... ");
		i = GrammarInformation::build(l);
		set[Violation] vs = smellsInGrammar(i);
		append <l,i,vs>;
	}
	
	return
		[ <l, i, vs>
		| <l, i, vs> <- triples
		, grammarInfo(grammar(ns,_,_),_,_) := i
		, size(ns) > 0
		];
}

void doesAPermutationIncreaseReferenceInfo(loc l) = doesAPermutationIncreaseReferenceInfo(l, 30000);
void doesAPermutationIncreaseReferenceInfo(loc l, int n ) {
	println(l);
	gInfo = GrammarInformation::build(l);
	vs = smellsInGrammar(gInfo);
		
	list[GProd] ps = gInfo.g.P;
	real original = smells::UpDownReferences::getReferenceInfo(gInfo).ratio;
	for(x <- [0..n]) {
		iprintln(x);
		perm = aPermutation(ps);
		gInfo.g.P = perm;
		permRatio = smells::UpDownReferences::getReferenceInfo(gInfo).ratio;
		if (permRatio > original) {
			println(perm);
			return;
		}
	}
}

list[str] upDownViolationForNonterminalDue(loc l, str n) {
	gInfo = GrammarInformation::build(l);
	vs = smellsInGrammar(gInfo);
	return toList(head([reason | <_, misplacedNonterminal(reason,n)> <- vs]));
}

void printLoc(loc l) {
	gInfo = GrammarInformation::build(l);
	println(ppx(gInfo.g));
}
void printGrammarAndOptimizeForUpDown(loc l){
	gInfo = GrammarInformation::build(l);
	//println(ppx(gInfo.g));
	optimizedGInfo = smells::UpDownReferences::optimize(gInfo, true);
	
	
	println();
	iprintln(smells::ReferenceDistance::referenceDistances(gInfo));
	println();
	iprintln(smells::ReferenceDistance::referenceDistances(optimizedGInfo));
	println();
	//println(ppx(optimizedGInfo.g));
	
	iprintln(smells::UpDownReferences::violations(optimizedGInfo));
}
void upDownOptimize() {
	begin = now();
	println("TODO UNCOMMENT ALL!");
	
	
	lrel[loc, GrammarInfo, set[Violation]] triples = getInputFiles();
 	for (<a,gInfo,c> <- triples) {
 		println(a);
 		list[GProd] ps = gInfo.g.P;
 		real original = smells::UpDownReferences::getReferenceInfo(gInfo).ratio;
 		for(x <- [0..30000]) {
 			iprintln(x);
 			perm = aPermutation(ps);
 			gInfo.g.P = perm;
 			permRatio = smells::UpDownReferences::getReferenceInfo(gInfo).ratio;
 			if (permRatio > original) {
				println(perm);
				return;
			}
 		}
 			
 		
 		//println(smells::ReferenceDistance::referenceDistances(gInfo));
 		//println(ppx(gInfo.g));
 		//let (
 		//optimizedGInfo = smells::UpDownReferences::optimize(gInfo, true);
 		//println(smells::UpDownReferences::getReferenceInfo(optimizedGInfo));
 		//println(smells::ReferenceDistance::referenceDistances(optimizedGInfo));
 		//println(ppx(optimizedGInfo.g));
 	}
}

list[&T] aPermutation(list[&T] input) {
	if (input == []) return [];
	x = getOneFrom(input);
	list[&T] rest = (input - x);
	return x + aPermutation(rest);
}
//void referenceDistanceAnalysis() {
//	lrel[loc, GrammarInfo, set[Violation]] triples = getInputFiles();
//
//	for (<a,b,vs> <- triples) {
//		iprintln(smells::UpDownReferences::getReferenceInfo(b));
//		set[str] violatingNs = { n | v:<violatingNonterminal(n),misplacedNonterminal(level, n)> <- vs};
//		iprintln(size({ p.lhs | p <- b.g.P}));
//		iprintln(size(violatingNs));
//	}
//	
//}

void analysis() {
	begin = now();	
	lrel[loc, GrammarInfo, set[Violation]] triples = getInputFiles();
	smells::MixedDefinitions::analysis(triples);
}

bool isContextFree(GGrammar g ) {
	for (p <- g.P, /not(_) := p.rhs) {
		return false;
	}
	return true;
}

void export() {
	begin = now();
	println("TODO UNCOMMENT ALL!");
	
	
	lrel[loc, GrammarInfo, set[Violation]] inputFiles = getInputFiles();
	lrel[loc, GrammarInfo, set[Violation]] triples = [ i | i:<_,gInfo,_> <- inputFiles, isContextFree(gInfo.g) ];
	
	println("<size(triples)> input files.");
	
	println("Write grammar stats");
	writeGrammarStats(triples);
	
	println("Write mixed definition stats ...");
	smells::MixedDefinitions::writeMixedDefinitionStats(triples);
	
	println("Write mixed up and down referencing stats ...");
	smells::UpDownReferences::export(triples);
	optimizedTriples = [ <a, smells::UpDownReferences::optimize(b, false), c> | <a, b, c> <- triples, a == printExp("\n \> File: ",a) ];
	println(""); 
	smells::UpDownReferences::exportOptimized(optimizedTriples);
	
	println("Write duplication stats ...");
	smells::Duplication::export(triples);
	
	println("Write improper responsibility stats ...");
	smells::ImproperResponsibility::export(triples);
	
	println("Write redirecting non terminal stats ...");
	exportRedirectingNonterminalSmellData(triples);
	
	println("Write complexity stats ...");
	smells::Complexity::export(triples);
	
	println("Write naming stats ...");
	smells::NamingConvention::export(triples);
	
	println("Write diconnected nonterminal data");
	smells::DisconnectedNonterminalGraph::export(triples);
	
	
	println("Write massagable data");
	smells::Massagable::export(triples);
	
	println("Write scattered nonterminals");
	smells::ScatteredNonterminalProductionRules::export(triples);
	
	println("Write single list thingy data");
	smells::SingleListThingy::export(triples);
	
	println("Write mixed top data");
	smells::MixedTop::export(triples);
	
	println("Write reference distance data");
	smells::ReferenceDistance::export(triples);
	
	println("Write multi tops data");
	smells::MultiTops::export(triples);
	
	println("Write size data");
	smells::Size::export(triples);
	
	println("Write small abstrattions");
	smells::SmallAbstractions::export(triples);
	
	println("Write legacy structures");
	smells::LegacyStructures::export(triples);
	
	println("Write explicit ambiguity");
	smells::ExplicitAmbiguity::export(triples);
	
	println("Write traveling family");
	smells::TravelingFamily::export(triples);
	
	println("Write constants");
	writeConstants(inputFiles, triples);
	
	end = now();
	println("Start: <begin>");
	println("End:   <end>");
}

void writeConstants(lrel[loc, GrammarInfo, set[Violation]] inputTriples, lrel[loc, GrammarInfo, set[Violation]] triples) {
	list[loc] inputFiles = Input::extractedGrammarLocationsInDir(|project://grammarsmells/input/zoo|);
	
	int totalInputGrammars = size(inputFiles);
	int wipGrammars = ( 0 | it + 1 |  l <- inputFiles, contains("<l>", "%A7wip/"));
	int emptyGrammars = totalInputGrammars - wipGrammars - size(triples);
	int selectedGrammars = size(triples);
	
	map[str, value] constants = 
		( "total-input-grammars": totalInputGrammars
		, "wip-grammars": wipGrammars
		, "empty-grammars" : emptyGrammars
		, "selected-grammars" : selectedGrammars
		, "nonCFGs" : size(inputTriples) - size(triples)
		);
		
	IO::writeFile(|project://grammarsmells/output/constants.json|, toJSON(constants, true));
}

void runSize() {
	for (<l,i> <- getInputFiles()) {
		iprintln(l);
		iprintln(
		smells::Size::stuff(i)
		)
		;
	}
}

void exportRedirectingNonterminalSmellData (list[GrammarAnalysis] result) {
	map[str, map[str, value]] byFile = 
		( "<l>" : 
			( "count" : size(ns)
			, "ns" : ns
			)
		| <l,g,vs> <- result
		, ns := [ lhs | v <- vs , <violatingNonterminal(lhs),redirectingNonterminal()> := v]
		);
	IO::writeFile(|project://grammarsmells/output/redirecting-nonterminals-by-file.json|, toJSON(byFile, true));
}

void writeGrammarStats(list[tuple[loc, GrammarInfo,set[Violation]]] inputFiles) {
	list[value] x = [ grammarStatsJson(l, gInfo) | <l,gInfo,vs> <- inputFiles];
	IO::writeFile(|project://grammarsmells/output/grammar-stats.json|, toJSON(x, true));
}

value grammarStatsJson(loc l, grammarInfo(g:grammar(ns,ps,ss), grammarData(references,_,_,tops,bottoms), facts)) =
		( "location": "<l>"
		, "nonterminals" : size(ns)
		, "productions" : size(ps)
		, "tops" : size(tops)
		, "bottoms" :size(bottoms)
		, "facts": ( String::replaceFirst("<fk>","()","") : facts[fk] | fk <- facts)
		, "references": size(references)
		);


set[Violation] smellsInGrammar(gInfo) =
	  smells::DisconnectedNonterminalGraph::violations(gInfo)
	+ smells::Duplication::violations(gInfo)
	+ smells::EntryPoint::violations(gInfo)
	+ smells::ImproperResponsibility::violations(gInfo)
	+ smells::LegacyStructures::violations(gInfo)
	+ smells::MixedDefinitions::violations(gInfo)
	+ smells::MixedTop::violations(gInfo)
	+ smells::ProxyNonterminals::violations(gInfo)
	+ smells::ReferenceDistance::violations(gInfo)
	+ smells::ScatteredNonterminalProductionRules::violations(gInfo)
	+ smells::SingleListThingy::violations(gInfo)
	+ smells::SmallAbstractions::violations(gInfo)
	+ smells::UpDownReferences::violations(gInfo)
	+ smells::Massagable::violations(gInfo)
	+ smells::ExplicitAmbiguity::violations(gInfo)
	+ smells::MultiTops::violations(gInfo)
	+ smells::TravelingFamily::violations(gInfo)
	;

