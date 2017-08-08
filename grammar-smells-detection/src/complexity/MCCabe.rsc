module complexity::MCCabe

import grammarlab::language::Grammar;
import List;
import IO;

int compute(nonterminal(_)) = 0;
int compute(terminal(_)) = 0;
int compute(val(_)) = 0;
int compute(epsilon()) = 0;
int compute(empty()) = 0;
int compute(anything()) = 0;

int compute (not(x)) = compute(x);

int compute(plus(x)) = compute(x) + 1;
int compute(star(x)) = compute(x) + 1;
int compute(optional(x)) = compute(x) + 1;

int compute(sequence(xs)) = sum([compute(x) | x <- xs ]);
int compute(choice(xs)) = sum([compute(x) | x <- xs]) + size(xs) - 1;
int compute(label(_, x)) = compute(x);
int compute(mark(_, x)) = compute(x);
int compute(seplistplus(x, y)) = compute(x) + compute(y) + 1;
int compute(sepliststar(x, y)) = compute(x) + compute(y) + 1;
int compute(GExpr e) {
	iprintln(e);
	return 0;
}
//Tests

test bool testMccabe1() = compute(sequence([ terminal("OPEN"), plus(nonterminal("b"))])) == 1;
test bool testMccabe2() =
	8 ==
	compute(
		sequence(
			[ terminal("OPEN")
			, plus(
				choice(
					[ sequence(
						[ terminal("INPUT")
						, plus(nonterminal("file_name"))
						])
					, sequence(
						[ terminal("OUTPUT")
						, plus(nonterminal("file_name"))
              			])
          			, sequence(
          				[ terminal("I-O")
          				, plus(nonterminal("file_name"))
          				])
      				, sequence(
      					[ terminal("EXTEND")
      					, plus(nonterminal("file_name"))
              			])
          			]
  				))
    		]));
