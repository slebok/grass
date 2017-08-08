const duplication = require("../../output/duplication");
const _ = require("lodash");
const gsu = require("../grammar-stats-util");
const base = require("../base");
const corpusInfo = require("../corpus-info");

//No NS Rules
const resNoNs = duplication.map(x => {
    const totalProds = _.sum(
        x.duplicateRulesNotNonterminals.map(x => x.nonterminals.length)
    );

    const stat = gsu.statForFile(x.location);
    return [x.location, base.rawPerc(totalProds, stat.productions)];
});
const noNsNoDupRulesFiles = resNoNs.filter(x => x[1] == 0).length;
const totalProdsNoNs = _.sum(
    _.map(duplication, x =>
        _.sum(
            _.map(x.duplicateRulesNotNonterminals, y => y.nonterminals.length)
        )
    )
);

//Full Rules
const resAllRules = duplication.map(x => {
    const totalProds = _.sum(x.duplicateRules.map(x => x.nonterminals.length));
    const stat = gsu.statForFile(x.location);
    return [x.location, base.rawPerc(totalProds, stat.productions)];
});
const dupRulesFiles = resAllRules.filter(x => x[1] == 0).length;
const totalProds = _.sum(
    _.map(duplication, x =>
        _.sum(_.map(x.duplicateRules, y => y.nonterminals.length))
    )
);
//Export

const statDuplicateRules = require("../duplication/util").ruleStats(
    duplication,
    "duplicateRules"
);
const statDuplicateRulesNoNs = require("../duplication/util").ruleStats(
    duplication,
    "duplicateRulesNotNonterminals"
);

// Defined subexpressions
const allDefinedSubExpressions = _.flatten(
    duplication.map(x => x.definedSubExpressions.map(y => [x.location, y]))
);

const allFactKeys = Object.keys(allDefinedSubExpressions[0][1].prodFacts);
const factSeparated = allFactKeys.map(k => {
    return [k, allDefinedSubExpressions.filter(x => x[1].prodFacts[k]).length];
});

function isOther(x) {
    return !_.reduce(
        allFactKeys,
        (base, y) => base || x[1].prodFacts[y],
        false
    );
}
const factKey = "sequence";
const candidates = _.take(
    _.shuffle(allDefinedSubExpressions.filter(isOther)),
    10
);

// allDefinedSubExpressions.filter(x => x[1].prodFacts[factKey]).forEach(x => {
//     console.log(x[0]);
// });

// allDefinedSubExpressions.filter(x => x[1].prodFacts[factKey]).forEach(x => {
//     console.log(x[0]);
// });

// console.log();
// console.log(
//     "Count:",
//     allDefinedSubExpressions.filter(x => x[1].prodFacts[factKey]).length
// );
// console.log();
// candidates.forEach(candidate => {
//     console.log(
//         candidate[0]
//             .replace(
//                 "|project://grammarsmells/input",
//                 "http://slebok.github.io"
//             )
//             .replace("grammar.bgf|", "index.html")
//     );
//     console.log(candidate[1].targets);
//     console.log();
// });
// const affectedNonterminalsKnownSubexpressions = _.sum(
//     duplication.map(
//         x =>
//             _.intersection(
//                 x.definedSubExpressions.map(
//                     y => y.sources[0] + "_/_" + y.nonterminal[1]
//                 )
//             ).length
//     )
// );
//
// const affectedTargetProductionNonterminalsKnownSubexpressions = _.sum(
//     duplication.map(
//         x =>
//             _.intersection(
//                 x.definedSubExpressions.map(y => y.prod[0] + "_/_" + y.prod[1])
//             ).length
//     )
// );

// console.log(affectedTargetProductionNonterminalsKnownSubexpressions);
const knownSubexpressionsAffectedFiles = duplication.filter(
    x => x.definedSubExpressions.length > 0
);

// console.log(factSeparated);

// const some = allDefinedSubExpressions.map(x => x[1].targets.length);
// some.forEach(x => {
//     console.log(x);
// });

module.exports = {
    "duplication/rules/total-prods": statDuplicateRules.totalProds,
    "duplication/rules/total-prods-perc": statDuplicateRules.totalProdsPerc,
    "duplication/rules/files-without": statDuplicateRules.filesWithout,
    "duplication/rules/files-without-perc": statDuplicateRules.filesWithoutPerc,
    "duplication/rules/mean-percentage": statDuplicateRules.meanPercentage,

    "duplication/rules-no-ns/total-prods": statDuplicateRulesNoNs.totalProds,
    "duplication/rules-no-ns/total-prods-perc":
        statDuplicateRulesNoNs.totalProdsPerc,
    "duplication/rules-no-ns/files-without":
        statDuplicateRulesNoNs.filesWithout,
    "duplication/rules-no-ns/files-without-perc":
        statDuplicateRulesNoNs.filesWithoutPerc,
    "duplication/rules-no-ns/mean-percentage":
        statDuplicateRulesNoNs.meanPercentage,
    "duplication/known-subexpressions/affected-files":
        knownSubexpressionsAffectedFiles.length,
    "duplication/known-subexpressions/affected-files-perc": base.perc(
        knownSubexpressionsAffectedFiles.length,
        corpusInfo.fileCount()
    ),
    "duplication/known-subexpressions/violations":
        allDefinedSubExpressions.length
};

// console.log(module.exports);
