module Size

import GrammarInformation;
import grammarlab::language::Grammar;
import List;

int expressionSize(GExpr e) {
	int i = 0;
	visit(e) {
		case nonterminal(_): i = i + 1;
		case terminal(_): i = i + 1;
		case plus(_): i = i + 1;
		case star(_): i = i + 1;
		case choice(xs): i = i + size(xs) - 1;
		case optional(_): i = i + 1;
		case anything(): i = i + 1;
		case epsilon():  i = i + 1;
	}
	return i;
}
