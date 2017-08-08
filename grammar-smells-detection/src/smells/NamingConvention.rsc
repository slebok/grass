module smells::NamingConvention

import IO;
import grammarlab::language::Grammar;
import GrammarUtils;
import List;
import Set;
import Relation;
import GrammarInformation;
import Violations;
import String;
import lang::json::IO;

data NamingClass
	= lowerCasedHyphened()
	| lowerCasedUnderscored()
	| lowerCasedDotted()
	| lowerCased()
	| lowerCasedHyphenedWithAttributes()
	| upperCasedHyphened()
	| upperCasedUnderscored()
	| upperCasedDotted()
	| upperCased()
	| camelCasedHyphened()
	| camelCasedUnderscored()
	| camelCasedDotted()
	| camelCased()
	| mixedCasedHyphened()
	| mixedCasedUnderscored()
	| mixedCasedDotted()
	| mixedCased()
	| anyHyphened()
	| anyUnderscored()
	| anyDotted()
	| undecided()
	| unknown()
	| notPresent()
	;

list[str] allClasses = 
	[ "<lowerCasedHyphened()>"
	, "<lowerCasedUnderscored()>"
	, "<lowerCasedDotted()>"
	,"<lowerCased()>"
	,"<lowerCasedHyphenedWithAttributes()>"
	,"< upperCasedHyphened()>"
	,"< upperCasedUnderscored()>"
	,"< upperCasedDotted()>"
	,"< upperCased()>"
	,"< camelCasedHyphened()>"
	,"< camelCasedUnderscored()>"
	,"< camelCasedDotted()>"
	,"< camelCased()>"
	,"< mixedCasedHyphened()>"
	,"< mixedCasedUnderscored()>"
	,"< mixedCasedDotted()>"
	,"< mixedCased()>"
	,"< anyHyphened()>"
	,"< anyUnderscored()>"
	,"< anyDotted()>"
	,"< undecided()>"
	,"< unknown()>"
	,"< notPresent() >"
	];
	

bool lowerCaseHyphen(str n) = /^[a-z0-9]+(-[a-z0-9]+)*-?$/ := n;
bool lowerCaseUnderscore(str n)   = /^[a-z0-9]+(_[a-z0-9]+)*_?$/ := n;
bool lowerCaseDot(str n)   = /^[a-z0-9]+(\.[a-z0-9]+)*$/ := n;
bool lowerCase(str n) 		= /^[a-z0-9]+$/ := n;

bool lowerCasedHypheneWithAttributes(str n) = /^[a-z0-9]+(-[a-z0-9]+)*-?(\.[a-z]+)?$/ := n;
bool upperCaseHyphen(str n) = /^[A-Z0-9]+(-[A-Z0-9]+)*-?$/ := n;
bool upperCaseUnderscore(str n) = /^[A-Z0-9]+(_[A-Z0-9]+)*_?$/ := n;
bool upperCaseDot(str n) = /^[A-Z0-9]+(\.[A-Z0-9]+)*$/ := n;
bool upperCase(str n) = /^[A-Z0-9]+$/ := n;

bool camelCaseHyphen(str n) = /^[A-Z]+[a-z0-9]*(-[A-Z]+[a-z0-9]*)*-?$/ := n;
bool camelCaseUnderscore(str n) = /^[A-Z]+[a-z0-9]*(_[A-Z]+[a-z0-9]*)*_?$/ := n;
bool camelCaseDot(str n) = /^[A-Z]+[a-z0-9]*(\.[A-Z]+[a-z0-9]*)*$/ := n;
bool camelCase(str n) = /^([A-Z]+[a-z0-9]*)+$/ := n;

bool mixedCaseHyphen(str n) = /^[a-z0-9]+([A-Z][A-Za-z0-9]*)*(-[a-z0-9]+([A-Z][A-Za-z0-9]*)*)*$/ := n;
bool mixedCaseUnderscore(str n) = /^[a-z0-9]+(_[A-Z][A-Za-z0-9]*)*$/ := n;
bool mixedCaseDot(str n) = /^[a-z0-9]+(\.[A-Z][A-Za-z0-9]*)*$/ := n;
bool mixedCase(str n) = /^[a-z0-9]+([A-Z][A-Za-z0-9]*)*$/ := n;

bool anyHyphen(str n) = /^[A-Za-z0-9]+(-[A-Za-z0-9]+)+$/ := n;
bool anyUnderscore(str n) = /^[A-Za-z0-9]+(_[A-Za-z0-9]+)+$/ := n;
bool anyDot(str n) = /^[A-Za-z0-9]+(\.[A-Za-z0-9]+)+$/ := n;

rel[NamingClass, bool(str)] namingClasses = 
	{ <lowerCasedHyphened(), lowerCaseHyphen>
	, <lowerCasedHyphenedWithAttributes(), lowerCasedHypheneWithAttributes> 
	, <lowerCasedUnderscored(), lowerCaseUnderscore>
	, <lowerCasedDotted(), lowerCaseDot>
	, <lowerCased(), lowerCase>
	, <upperCasedHyphened(), upperCaseHyphen>
	, <upperCasedUnderscored(), upperCaseUnderscore>
	, <upperCasedDotted(), upperCaseDot>
	, <upperCased(), upperCase>
	, <camelCasedHyphened(), camelCaseHyphen>
	, <camelCasedUnderscored(), camelCaseUnderscore>
	, <camelCasedDotted(), camelCaseDot>
	, <camelCased(), camelCase>
	, <mixedCasedHyphened(), mixedCaseHyphen>
	, <mixedCasedUnderscored(), mixedCaseUnderscore>
	, <mixedCasedDotted(), mixedCaseDot>
	, <mixedCased(), mixedCase>
	, <anyHyphened(), anyHyphen>
	, <anyUnderscored(), anyUnderscore>
	, <anyDotted(), anyDot>
	};
	
	
rel[NamingClass, NamingClass] strongerRel =
	{ <camelCased(), camelCasedUnderscored()>
	, <camelCased(), camelCasedHyphened()>
	, <camelCased(), camelCasedDotted()>
	
	, <mixedCased(), mixedCasedUnderscored()>
	, <mixedCased(), mixedCasedHyphened()>
	, <mixedCased(), mixedCasedDotted()>
	
	, <lowerCased(), lowerCasedUnderscored()>
	, <lowerCased(), lowerCasedHyphened()>
	, <lowerCased(), lowerCasedDotted()>
	
	, <lowerCasedHyphened(), lowerCasedHyphenedWithAttributes()>
	
	, <upperCased(), upperCasedUnderscored()>
	, <upperCased(), upperCasedHyphened()>
	, <upperCased(), upperCasedDotted()>
	
	
	, <lowerCasedUnderscored(), anyUnderscored()>
	, <lowerCasedHyphened(), anyHyphened()>
	, <lowerCasedDotted(), anyDotted()>
	
	, <upperCasedUnderscored(), camelCasedUnderscored()>
	, <lowerCased(), mixedCased()>
	, <upperCased(), camelCased()>
	, <upperCasedHyphened(), camelCasedHyphened()>
	}+
	;	 

	
test bool lowerCaseHyphen1() = lowerCaseHyphen("abc-def");
test bool lowerCaseHyphen2() = lowerCaseHyphen("abc-");
test bool lowerCaseHyphen3() = !lowerCaseHyphen("abc-Def");
test bool lowerCaseHyphen4() = lowerCaseHyphen("abc-3d");


test bool lowerCasedHypheneWithAttributes1() = lowerCasedHypheneWithAttributes("abc-def.model");
test bool lowerCasedHypheneWithAttributes2() = lowerCasedHypheneWithAttributes("abc-def");
test bool lowerCasedHypheneWithAttributes3() = !lowerCasedHypheneWithAttributes("abc-def.A");

test bool upperCaseUnderscore1() = upperCaseUnderscore("LT_"); 
	
test bool lowerCaseUnderscore1() = lowerCaseUnderscore("abc_def");
test bool lowerCaseUnderscore2() = lowerCaseUnderscore("abc_");
test bool lowerCaseUnderscore3() = !lowerCaseUnderscore("abc_Def");
test bool lowerCaseUnderscore4() = lowerCaseUnderscore("abc_3d");

test bool testCamelCase1() = camelCase("COBOLUsageValue");

test bool testCamelCaseUnderscore1() = !camelCaseUnderscore("COBOLUsageValue");
test bool testCamelCaseUnderscore2() = camelCaseUnderscore("COBOLUsage");

test bool testAnyUnderscore1() = anyUnderscore("C_compilation_unit");

test bool mixedCase1() = mixedCase("anyElement");
test bool mixedCaseHyphen1() = mixedCaseHyphen("fooBar-some");	
	

rel[NamingClass,str] buildNamingRelation(set[str] ns) {
	r = { <v,n> | n <- ns, <v,f> <- namingClasses, f(n)};
	if (size(domain(r)) <= 1) {
		return {};
	}
	
	return r;	
}

bool isTerminalDefinition(str n, GrammarInfo gInfo) {
	list[GProd] prods = gInfo.d.nprods[n];
	if (size(prods) == 1) {
		GProd prod = getOneFrom(prods);
		return terminal(_) := prod.rhs || val(_) := prod.rhs || anything() := prod.rhs;
	} else {
		return false;
	}
}

set[str] allNonterminalsThatAreJustTerminalDefinitions(GrammarInfo gInfo) {
	return { n | n <- gInfo.g.N, isTerminalDefinition(n, gInfo)}; 
}

NamingClass namingConventionForNonterminals(set[str] ns) {
	if (ns == {}) {
		return notPresent();
	}
	result = { p | <p,f> <- namingClasses, all(n <- ns, f(n)) };
	
	if(result == {}) {
		return unknown();
	} else if ({x} := result) {
		return x;
	} else {
		set[NamingClass] trimmed = result - { a | a <- result, b <- result, <b,a> in strongerRel};
		if(size(trimmed) == 1) {
			return getOneFrom(trimmed);
		} else {
			return undecided();
		}
	}
}

map[str,value] dataForGrammar(loc l, GrammarInfo gInfo) {
	g = gInfo.g;
	set[str] terminalDefs = allNonterminalsThatAreJustTerminalDefinitions(gInfo);
	NamingClass terminalDefStyle = namingConventionForNonterminals(terminalDefs);
	NamingClass fullDefStyle = namingConventionForNonterminals(toSet(g.N));
	NamingClass fullDefMinusTerminalDefsStyle = namingConventionForNonterminals(toSet(g.N) - terminalDefs);

	return (
		"location": "<l>",
		"overall": "<fullDefStyle>",
		"minusTerminalDefinitions": "<fullDefMinusTerminalDefsStyle>",
		"terminalDefinitions": "<terminalDefStyle>"
	);
}

void infoForLoc(loc l) {
	GrammarInfo gInfo = GrammarInformation::build(l);
	set[str] ns = toSet(gInfo.g.N);
	
	list[tuple[NamingClass, real]] pairs;
	pairs = for (<k,f> <- namingClasses) {
		set[str] comply = { n | n <- ns, f(n) };
		perc =  (size(comply) * 1.0 / size(ns));	
		append < k, perc>;
	}
	sorted = sort(pairs, bool(tuple[NamingClass,real] a,tuple[NamingClass,real] b) { return a[1] < b[1]; });
	iprintln(sorted);
	
	iprintln({ <n, { k | <k,f> <- namingClasses, f(n)}>  | n <- ns, !lowerCaseUnderscore(n) && !anyUnderscore(n) });
}
void export(lrel[loc, GrammarInfo, set[Violation]] triples) {
	list[map[str,value]] namingData = [];
	namingData = [ dataForGrammar(l, gInfo) | <l, gInfo, vs> <- triples];
	IO::writeFile(
		|project://grammarsmells/output/naming.json|,
		toJSON( ( "files" : namingData, "namings" : allClasses ), true)
	);
}

