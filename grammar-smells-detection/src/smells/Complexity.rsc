module smells::Complexity

import grammarlab::language::Grammar;
import grammarlab::export::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import Violations;
import List;
import GrammarInformation;
import lang::json::IO;
import smells::Size;
import util::Math;
import complexity::MCCabe;
import complexity::NestingDegree;
import complexity::OperationBased;

real outlierThreshold = 0.95;

void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	x = [ analyseInfo(l, gInfo) | <l,gInfo,_> <- triples];
	
	complexityData = (
		"outlierthreshold": outlierThreshold,
		"files" : x
	);
	
	IO::writeFile(
		|project://grammarsmells/output/complexity.json|,
		toJSON( complexityData, true)
	);
}
map[str,value] analyseInfo(loc l, grammarInfo(g, grammarData(_, _, expressionIndex,_,_), facts)) {
	list[int] mccabeValues = [complexity::MCCabe::compute(p.rhs) | p <- g.P];
	list[int] nestingDegreeValues = [complexity::NestingDegree::compute(p.rhs) | p <- g.P];
	list[int] combinedValues = [complexity::OperationBased::compute(p.rhs) | p <- g.P];
	
	real threshold = outlierThreshold;
	int mccabeOutlierValue = getOutlierValue(mccabeValues, threshold);
	int nestingDegreeOutlierValue = getOutlierValue(nestingDegreeValues, threshold);
	int combinedOutlierValue = getOutlierValue(combinedValues, threshold);

	//McCabe 		
	list[GProd] mccabePositives = findMcCabePositives(g,mccabeOutlierValue, nestingDegreeOutlierValue, combinedOutlierValue);
	list[int] mccabePositivesIndexes = [ indexOf(g.P, p) | p <- mccabePositives];
	
	list[GProd] mccabePositivesSimpleChoice = [ p | p <- mccabePositives, isSimpleChoiceExpression(p.rhs) ];
	list[int] mccabePositivesSimpleChoiceIndexes = [ indexOf(g.P, p) | p <- mccabePositivesSimpleChoice];
	
	list[GProd] mccabePositivesSimpleSequence = [ p | p <- mccabePositives, isSimpleSequenceExpression(p.rhs)];
	list[int] mccabePositivesSimpleSequenceIndexes = [ indexOf(g.P, p) | p <- mccabePositivesSimpleSequence];
	
	//Nested Degree
	list[GProd] nestedDegreePositives = findNestedDegreePositives(g, mccabeOutlierValue, nestingDegreeOutlierValue, combinedOutlierValue);
	list[int] nestedDegreeIndexes = [ indexOf(g.P, p) | p <- nestedDegreePositives];
	
	//Combined
	list[GProd] combinedPositives = findCombinedPositivies(g, mccabeOutlierValue, nestingDegreeOutlierValue, combinedOutlierValue);
	list[int] combinedPositivesIndexes = [ indexOf(g.P, p) | p <- combinedPositives];
	
	//Overall
	list[GProd] overallPositives = findOverallPositives(g, mccabeOutlierValue, nestingDegreeOutlierValue, combinedOutlierValue);
	list[int] overallPositivesIndexes = [ indexOf(g.P, p) | p <- overallPositives];
	
	
	return (
		"location": "<l>",
		"mccabe" : (
			"outlier": mccabeOutlierValue,
			"indexes": mccabePositivesIndexes,
			"simpleChoiceIndexes": mccabePositivesSimpleChoiceIndexes,
			"simpleSequenceIndexes": mccabePositivesSimpleSequenceIndexes
		),
		"nestingDegree": (
			"indexes": nestedDegreeIndexes
		),
		"combined": (
			"indexes": combinedPositivesIndexes
		),
		"overall": (
			"indexes": overallPositivesIndexes
		)
	);

	return {};
}

bool isSimpleChoiceExpression(GExpr e) =
 	 choice(xs) := e && all(x <- xs, isTerminalOrNonterminal(x));
 	  
bool isTerminalOrNonterminal(GExpr x) =
	terminal(t) := x || nonterminal(n) := x;
	
bool isSimpleSequenceExpression(GExpr e) =
 	 sequence(xs) := e && all(x <- xs, isAtMost1Mcc(x));

bool isAtMost1Mcc(GExpr e) = complexity::MCCabe::compute(e) <= 1;
 	
test bool testIsSimpleChoiceExpression() =
	isSimpleChoiceExpression(choice([
        terminal("="),
        terminal("*="),
        terminal("/="),
        terminal("%="),
        terminal("+="),
        terminal("-="),
        terminal("\<\<="),
        terminal("\>\>="),
        terminal("&="),
        terminal("^="),
        terminal("|=")
      ]));
      
list[GProd] findOverallPositives(GGrammar g, int mccabeOutlier, int nestingDegreeOutlier, int combinedOutlier) {
	return for (p <- g.P) {
		int m = complexity::MCCabe::compute(p.rhs);
		int n = complexity::NestingDegree::compute(p.rhs);
		int c = complexity::OperationBased::compute(p.rhs);
		if ( m >= mccabeOutlier && n >= nestingDegreeOutlier  && c >= combinedOutlier ) {
			append p;
		} 
	}
}

list[GProd] findCombinedPositivies(GGrammar g, int mccabeOutlier, int nestingDegreeOutlier, int combinedOutlier) {
	return for (p <- g.P) {
		int m = complexity::MCCabe::compute(p.rhs);
		int n = complexity::NestingDegree::compute(p.rhs);
		int c = complexity::OperationBased::compute(p.rhs);
		if ( m < mccabeOutlier && n < nestingDegreeOutlier  && c >= combinedOutlier ) {
			append p;
		} 
	}
}
list[GProd] findNestedDegreePositives(GGrammar g, int mccabeOutlier, int nestingDegreeOutlier, int combinedOutlier) {
	return for (p <- g.P) {
		int m = complexity::MCCabe::compute(p.rhs);
		int n = complexity::NestingDegree::compute(p.rhs);
		int c = complexity::OperationBased::compute(p.rhs);
		if ( m < mccabeOutlier && n >= nestingDegreeOutlier  && c < combinedOutlier ) {
			append p;
		} 
	}
}
list[GProd] findMcCabePositives(GGrammar g, int mccabeOutlier, int nestingDegreeOutlier, int combinedOutlier) {
	return for (p <- g.P) {
		int m= complexity::MCCabe::compute(p.rhs);
		int n = complexity::NestingDegree::compute(p.rhs);
		int c = complexity::OperationBased::compute(p.rhs);
		if ( m >= mccabeOutlier && n < nestingDegreeOutlier  && c < combinedOutlier ) {
			append p;
		} 
	}
}

int getOutlierValue( list[int] xs, real dropSize) {
	xs2 = [ x | x <- xs, x != 0];
	ys = drop(floor(size(xs2) * dropSize), sort(xs2));
	return ys == [] ? 9000 : ys[0];
}
