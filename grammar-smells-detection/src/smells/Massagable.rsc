module smells::Massagable

import grammarlab::io::read::BGF;
import GrammarInformation;
import grammarlab::language::Grammar;
import grammarlab::export::Grammar;
import GrammarUtils;
import Set;
import IO;
import Map;
import Map::Extra;
import List;
import Violations;
import util::Maybe;
import lang::json::IO;


set[Violation] violations(GrammarInfo gInfo) =	
	{ <violatingProduction(ls.p),massagableExpression(k, "<v>")>
	| fullExpr(k) <- gInfo.d.exprIndex
	, <f,v> <- massagables
	, f(k)
	, massagableAllowsValue(v) || /val(_) !:= k
	, ls <- gInfo.d.exprIndex[fullExpr(k)]
	};


bool massagableAllowsValue(choiceXAndX()) = false;
bool massagableAllowsValue(choiceXOptionalAndX()) = false;
bool massagableAllowsValue(choiceXPlusAndX()) = false;
bool massagableAllowsValue(choiceXStarAndX()) = false;

bool massagableAllowsValue(choiceXAndXOptional()) = false;
bool massagableAllowsValue(choiceXOptionalAndXOptional()) = false;
bool massagableAllowsValue(choiceXPlusAndXOptional()) = false;
bool massagableAllowsValue(choiceXStarAndXOptional()) = false;

bool massagableAllowsValue(choiceXAndXPlus()) = false;
bool massagableAllowsValue(choiceXOptionalAndXPlus()) = false;
bool massagableAllowsValue(choiceXPlusAndXPlus()) = false;
bool massagableAllowsValue(choiceXStarAndXPlus()) = false;

bool massagableAllowsValue(choiceXAndXStar()) = false;
bool massagableAllowsValue(choiceXOptionalAndXStar()) = false;
bool massagableAllowsValue(choiceXPlusAndXStar()) = false;
bool massagableAllowsValue(choiceXStarAndXStar()) = false;

bool massagableAllowsValue(sequenceXStarAndX()) = false;
bool massagableAllowsValue(sequenceXPlusAndXOptional()) = false;
bool massagableAllowsValue(sequenceXStarAndXOptional()) = false;
bool massagableAllowsValue(sequenceXOptionalAndXPlus()) = false;
bool massagableAllowsValue(sequenceXStarAndXPlus()) = false;
bool massagableAllowsValue(sequenceXAndXStar()) = false;
bool massagableAllowsValue(sequenceXOptionalAndXStar()) = false;
bool massagableAllowsValue(sequenceXPlusAndXStar()) = false;
bool massagableAllowsValue(sequenceXStarAndXStar()) = false;
	
bool massagableAllowsValue(Massagable _ ) = true; 


data Massagable 
	= choiceEpsilonAndEpsilon()
	| choiceXAndEpsilon()
	| choiceXOptionalAndEpsilon()
	| choiceXPlusAndEpsilon()
	| choiceXStarAndEpsilon()
	
	| choiceEpsilonAndX()
	| choiceXAndX()
	| choiceXOptionalAndX()
	| choiceXPlusAndX()
	| choiceXStarAndX()
	
	| choiceEpsilonAndXOptional()
	| choiceXAndXOptional()
	| choiceXOptionalAndXOptional()
	| choiceXPlusAndXOptional()
	| choiceXStarAndXOptional()
	
	| choiceEpsilonAndXPlus()
	| choiceXAndXPlus()
	| choiceXOptionalAndXPlus()
	| choiceXPlusAndXPlus()
	| choiceXStarAndXPlus()
	
	| choiceEpsilonAndXStar()
	| choiceXAndXStar()
	| choiceXOptionalAndXStar()
	| choiceXPlusAndXStar()
	| choiceXStarAndXStar()
	
	| compositionOptionalAfterOptional()
	| compositionPlusAfterOptional()
	| compositionStarAfterOptional()
	
	| compositionOptionalAfterPlus()
	| compositionPlusAfterPlus()
	| compositionStarAfterPlus()
	
	| compositionOptionalAfterStar()
	| compositionPlusAfterStar()
	| compositionStarAfterStar()
	
	| sequenceXStarAndX()
	| sequenceXPlusAndXOptional()
	| sequenceXStarAndXOptional()
	| sequenceXOptionalAndXPlus()
	| sequenceXStarAndXPlus()
	| sequenceXAndXStar()
	| sequenceXOptionalAndXStar()
	| sequenceXPlusAndXStar()
	| sequenceXStarAndXStar()
	;
	
	
bool isChoiceEpsilonAndEpsilon(GExpr x) =
	choice([_*,epsilon(),epsilon(),_*]) := x;

bool isChoiceXandEpsilon(GExpr x) = 
	choice([_*,y,epsilon(),_*]) := x && y != epsilon(); 

bool isChoiceXOptionalAndEpsilon(GExpr x) =
	choice([_*,optional(_),epsilon(),_*]) := x;

bool isChoiceXPlusAndEpsilon(GExpr x) =
	choice([_*,plus(_),epsilon(),_*]) := x;
	
bool isChoiceXStarAndEpsilon(GExpr x) =
	choice([_*,star(_),epsilon(),_*]) := x;
	

bool isChoiceEpsilonAndX(GExpr x) =
	choice([_*,epsilon(),y,_*]) := x  && y != epsilon();
	
bool isChoiceXAndX(GExpr x) =
	choice([_*,y,y,_*]) := x  && y != epsilon();
	
bool isChoiceXOptionalAndX(GExpr x) =
	choice([_*,optional(y),y,_*]) := x;
	
bool isChoiceXPlusAndX(GExpr x) =
	choice([_*,plus(y),y,_*]) := x;
	
bool isChoiceXStarAndX(GExpr x) =
	choice([_*,star(y),y,_*]) := x;
	

bool isChoiceEpsilonAndXOptional(GExpr x) =
	choice([_*,epsilon(),optional(y),_*]) := x;
	
bool isChoiceXAndXOptional(GExpr x) =
	choice([_*,y,optional(y),_*]) := x;
	
bool isChoiceXOptionalAndXOptional(GExpr x) =
	choice([_*,optional(y),optional(y),_*]) := x;
	
bool isChoiceXPlusAndXOptional(GExpr x) =
	choice([_*,plus(y),optional(y),_*]) := x;
	
bool isChoiceXStarAndXOptional(GExpr x) =
	choice([_*,star(y),optional(y),_*]) := x;
	
	
bool isChoiceEpsilonAndXPlus(GExpr x) =
	choice([_*,epsilon(),plus(y),_*]) := x;
	
bool isChoiceXAndXPlus(GExpr x) =
	choice([_*,y,plus(y),_*]) := x;
	
bool isChoiceXOptionalAndXPlus(GExpr x) =
	choice([_*,optional(y),plus(y),_*]) := x;
	
bool isChoiceXPlusAndXPlus(GExpr x) =
	choice([_*,plus(y),plus(y),_*]) := x;
	
bool isChoiceXStarAndXPlus(GExpr x) =
	choice([_*,star(y),plus(y),_*]) := x;
	

bool isChoiceEpsilonAndXStar(GExpr x) =
	choice([_*,epsilon(),star(y),_*]) := x;
	
bool isChoiceXAndXStar(GExpr x) =
	choice([_*,y,star(y),_*]) := x;
	
bool isChoiceXOptionalAndXStar(GExpr x) =
	choice([_*,optional(y),star(y),_*]) := x;
	
bool isChoiceXPlusAndXStar(GExpr x) =
	choice([_*,plus(y),star(y),_*]) := x;
	
bool isChoiceXStarAndXStar(GExpr x) =
	choice([_*,star(y),star(y),_*]) := x;
	

bool isCompositionOptionalAfterOptional(GExpr x) =
	optional(optional(_)) := x;
	
bool isCompositionPlusAfterOptional(GExpr x) =
	plus(optional(_)) := x;
	
bool isCompositionStarAfterOptional(GExpr x) =
	star(optional(_)) := x;
	 

bool isCompositionOptionalAfterPlus(GExpr x) =
	optional(plus(_)) := x;
	
bool isCompositionPlusAfterPlus(GExpr x) =
	plus(plus(_)) := x;
	
bool isCompositionStarAfterPlus(GExpr x) =
	star(plus(_)) := x;
	
	
bool isCompositionOptionalAfterStar(GExpr x) =
	optional(star(_)) := x;
	
bool isCompositionPlusAfterStar(GExpr x) =
	plus(star(_)) := x;
	
bool isCompositionStarAfterStar(GExpr x) =
	star(star(_)) := x;



bool isSequenceXStarAndX(GExpr x) =
	sequence([_*, star(y), y, _*]) := x;
	
bool isSequenceXPlusAndXOptional(GExpr x) =
	sequence([_*, plus(y), optional(y), _*]) := x;

bool isSequenceXStarAndXOptional(GExpr x) =
	sequence([_*, star(y), optional(y), _*]) := x;
	
bool isSequenceXOptionalAndXPlus(GExpr x) =
	sequence([_*, optional(y), plus(y), _*]) := x;
	
bool isSequenceXStarAndXPlus(GExpr x) =
	sequence([_*, star(y), plus(y), _*]) := x;
	
bool isSequenceXAndXStar(GExpr x) =
	sequence([_*, y, star(y), _*]) := x;
	
bool isSequenceXOptionalAndXStar(GExpr x) =
	sequence([_*, optional(y), star(y), _*]) := x;

bool isSequenceXPlusAndXStar(GExpr x) =
	sequence([_*, plus(y), star(y), _*]) := x;
	
bool isSequenceXStarAndXStar(GExpr x) =
	sequence([_*, star(y), star(y), _*]) := x;
	

lrel[(bool)(GExpr), Massagable] massagables =
	[ <isChoiceEpsilonAndEpsilon, choiceEpsilonAndEpsilon()>
	, <isChoiceXandEpsilon, choiceXAndEpsilon()>
	, <isChoiceXOptionalAndEpsilon, choiceXOptionalAndEpsilon()>
	, <isChoiceXPlusAndEpsilon, choiceXPlusAndEpsilon()>
	, <isChoiceXStarAndEpsilon, choiceXStarAndEpsilon()>
	
	, <isChoiceEpsilonAndX, choiceEpsilonAndX()>
	, <isChoiceXAndX, choiceXAndX()>
	, <isChoiceXOptionalAndX, choiceXOptionalAndX()>
	, <isChoiceXPlusAndX, choiceXPlusAndX()>
	, <isChoiceXStarAndX, choiceXStarAndX()>
	
	, <isChoiceEpsilonAndXOptional, choiceEpsilonAndXOptional()>
	, <isChoiceXAndXOptional, choiceXAndXOptional()>
	, <isChoiceXOptionalAndXOptional, choiceXOptionalAndXOptional()>
	, <isChoiceXPlusAndXOptional, choiceXPlusAndXOptional()>
	, <isChoiceXStarAndXOptional, choiceXStarAndXOptional()>
	 
	, <isChoiceEpsilonAndXPlus, choiceEpsilonAndXPlus()>
	, <isChoiceXAndXPlus, choiceXAndXPlus()>
	, <isChoiceXOptionalAndXPlus, choiceXOptionalAndXPlus()>
	, <isChoiceXPlusAndXPlus, choiceXPlusAndXPlus()>
	, <isChoiceXStarAndXPlus, choiceXStarAndXPlus()>
	
	, <isChoiceEpsilonAndXStar, choiceEpsilonAndXStar()>
	, <isChoiceXAndXStar, choiceXAndXStar()>
	, <isChoiceXOptionalAndXStar, choiceXOptionalAndXStar()>
	, <isChoiceXPlusAndXStar, choiceXPlusAndXStar()>
	, <isChoiceXStarAndXStar, choiceXStarAndXStar()>
	
	, <isCompositionOptionalAfterOptional, compositionOptionalAfterOptional()>
	, <isCompositionPlusAfterOptional, compositionPlusAfterOptional()>
	, <isCompositionStarAfterOptional, compositionStarAfterOptional()>
	
	, <isCompositionOptionalAfterPlus, compositionOptionalAfterPlus()>
	, <isCompositionPlusAfterPlus, compositionPlusAfterPlus()>
	, <isCompositionStarAfterPlus, compositionStarAfterPlus()>
	
	, <isCompositionOptionalAfterStar, compositionOptionalAfterStar()>
	, <isCompositionPlusAfterStar, compositionPlusAfterStar()>
	, <isCompositionStarAfterStar, compositionStarAfterStar()>
	
	, <isSequenceXStarAndX, sequenceXStarAndX()>
	, <isSequenceXPlusAndXOptional, sequenceXPlusAndXOptional()>
	, <isSequenceXStarAndXOptional, sequenceXStarAndXOptional()>
	, <isSequenceXOptionalAndXPlus, sequenceXOptionalAndXPlus()>
	, <isSequenceXStarAndXPlus, sequenceXStarAndXPlus()>
	, <isSequenceXAndXStar, sequenceXAndXStar()>
	, <isSequenceXOptionalAndXStar, sequenceXOptionalAndXStar()>
	, <isSequenceXPlusAndXStar, sequenceXPlusAndXStar()>
	, <isSequenceXStarAndXStar, sequenceXStarAndXStar()>
	];
	
	
void export(list[tuple[loc, GrammarInfo, set[Violation]]] input) {
	//Massagable targetMassagable = choiceXPlusAndX();

	occurences =
		{ <l,p.lhs, n>
		| <l,i,vs> <- input
		, v:<violatingProduction(p), massagableExpression(_,n)> <- vs};
		
	list[map[str,value]] massagableFileData = [];
	
	massagableFileData = for(<l,i,vs> <- input) {
		list[str] problems = [ n | <violatingProduction(p), massagableExpression(_,n)> <- vs ];
		fileResult =  (
			"location": "<l>",
			"problems": problems,
			"nonterminals": toList({p.lhs |  <violatingProduction(p), massagableExpression(_,n)> <- vs })
		);
		
		//if("<targetMassagable>" in problems
		//	, i.facts[containsPlus()]
		//	) {
		//	printForLoc(l, targetMassagable);
		//}
		append fileResult;
	}
	
	map[str,value] massagableData = (
		"totalFiles": size({l | <l,i,vs> <- input, <p,massagableExpression(_,_)> <- vs}),
		"occurences": size(occurences),
		"files": massagableFileData
	);
	
	IO::writeFile(
		|project://grammarsmells/output/massagable.json|,
		toJSON( massagableData, true)
	);
	
}

void printForLoc(loc l, Massagable m) {
	GrammarInfo gInfo = GrammarInformation::build(l);
	vs = violations(gInfo);
	println("Location: <l>");
	println("Violations (<size(vs)>)");
	int counter = 0;
	//iprintln(vs);
	for (<violatingProduction(p),massagableExpression(e, x)> <- vs, x == "<m>") {
		println("- Index(<indexOf(gInfo.g.P, p)>)");
		println("  <ppx(p)>");
		
	}
}

bool allAreEpsilon(list[GExpr] xs) {
	for (x <- xs) {
		if (x != epsilon()) {
			return false;
		}
	} 
	return true;
}
