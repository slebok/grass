const duplicationData = require("../../output/duplication");
const _ = require('lodash');
const gsutil = require("../grammar-stats-util.js");
const base = require('../base');

const prevalenceForProperty = function(f) {
    const pairs = duplicationData.map(x => [
        f(x),
        gsutil.statForFile(x.location).nonterminals
    ]);

    const affected = _.sum(_.map(pairs, 0));
    const total = _.sum(_.map(pairs, 1));
    return {affected: affected, total : total, percentage: base.perc(affected, total)}
}

console.log();
console.log("Prevalence of duplicate rules:");
const dupRules = prevalenceForProperty(x => x.duplicateRuleAffectedNonterminals.length);
console.log("> Affected nonterminals:", dupRules.affected);
console.log("> Total nonterminals:", dupRules.total);
console.log("> Percentage:", dupRules.percentage);
console.log();
console.log("Prevalence of defined sub expressions:");
const definedSubExpression = prevalenceForProperty(x => x.definedSubExpressionsAffectedNonterminals.length);
console.log("> Affected nonterminals:", definedSubExpression.affected);
console.log("> Total nonterminals:", definedSubExpression.total);
console.log("> Percentage:", definedSubExpression.percentage);
console.log();
console.log("Prevalence of common sub expression:");
const common = prevalenceForProperty(x => x.commonSubExpressionAffectedNonterminals.length);
console.log("> Affected nonterminals:", common.affected);
console.log("> Total nonterminals:", common.total);
console.log("> Percentage:", common.percentage);
