module complexity::NestingDegree

import grammarlab::language::Grammar;
import util::Math;
import List;


int compute(nonterminal(_)) = 0;
int compute(terminal(_)) = 0;
int compute(val(_)) = 0;
int compute(epsilon()) = 0;
int compute(empty()) = 0;
int compute(anything()) = 0;

int compute(label(_,e)) = compute(e);
int compute(mark(_,e)) = compute(e);

int compute (not(x)) = compute(x) + 1;
int compute(plus(x)) = compute(x) + 1;
int compute(star(x)) = compute(x) + 1;
int compute(optional(x)) = compute(x) + 1;

int compute(sequence(xs)) = max([ compute(x) | x <- xs]) + 1;
int compute(choice(xs)) = max([ compute(x) | x <- xs]) + 1;

int compute(seplistplus(x, y)) = max([compute(x),compute(y)]) + 1;
int compute(sepliststar(x, y)) = max([compute(x),compute(y)]) + 1;

