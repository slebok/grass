module Violations

import grammarlab::language::Grammar;


data ViolationLocation
	= violatingNonterminal(str n)
	| violatingNonterminals(set[str] ns)
	| violatingExpression(GExpr expr)
	| violatingExpressions(list[GExpr] exprs)
	| violatingProduction(GProd prod)
	| violatingProductions(set[GProd] prods)
	;
	
data ViolationReason
	= disconnectedFromTop()
	| duplicateRules()
	| definedSubExpression(GExpr e, set[GProd] haystack, set[GProd] needle)
	| commonSubExpression(GExpr e)
	| unclearEntryPoint()
	| fakeOneOrMore(GExpr e1, GExpr e2, GExpr e3)
	| fakeZeroOrMore()
	| improperResponsibilityNaive(list[GExpr] es)
	| improperResponsibilityImplicit(list[GExpr] es)
	| legacyUsage(LegacyUsage u)
	| mixedDefinition()
	| mixedTops()
	| multiTops()
	| noTops(set[set[str]] topLevels)
	| redirectingNonterminal()
	| singleUsageNonterminal(GProd ps)
	| referenceDistanceJumpOver(GProd a, GProd b, GProd c)
	| scatteredNonterminal()
	| singleListThingy(GExpr e)
	| counterDirectionReferencedProduction()
	| massagableExpression(GExpr e, str n)
	| misplacedNonterminal(set[str], str)
	| explicitAmbiguity(GExpr e, bool viaEpsilon)
	| distantElements(DistantElement d)
	;

data DistantElement
	= scatteredLevel(set[str] ns, list[tuple[int,GProd]] ps, list[tuple[int,GProd]] inner)
	| mixedInLevel(set[str] ns, list[tuple[int,GProd]] ps, list[tuple[int,GProd]] around)
	;

data LegacyUsage
	= legacyOptional(str n)
	| legacyPlus(str n)
	| legacyStar(str n)
	;
	
alias Violation = tuple[ViolationLocation, ViolationReason];