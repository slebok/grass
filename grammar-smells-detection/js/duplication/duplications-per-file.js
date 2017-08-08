const duplicationData = require("../../output/duplication");
const _ = require("lodash");
const corpusInfo = require("../corpus-info");

const numberOfDuplicateRules = _.flatten(
    _.map(_.flatten(_.map(duplicationData, "duplicateRules")), "nonterminals")
).length;

console.log("Files:", corpusInfo.fileCount());

///////////////////////////
///////////////////////////
///////////////////////////

const duplicateProductionRulesPrevalence =
    numberOfDuplicateRules / corpusInfo.totalProductionRules();
const filesContainingDuplicateRules = duplicationData.filter(
    x => x.duplicateRules.length > 0
).length;
const meanDuplicateRuleSize = _.mean(
    _.map(_.flatten(_.map(duplicationData, "duplicateRules")), "size")
);
const weightedMeanDuplicateRuleSize = _.mean(
    _.flatten(
        _.map(_.flatten(_.map(duplicationData, "duplicateRules")), x => {
            return x.nonterminals.map(_ => x.size);
        })
    )
);

console.log(
    (duplicateProductionRulesPrevalence * 100).toFixed(2),
    " of the production rules are a duplicate of something else"
);
console.log(
    filesContainingDuplicateRules,
    "of the files do contain duplicate rules. This is ",
    (filesContainingDuplicateRules / corpusInfo.fileCount() * 100).toFixed(2)
);
console.log("Mean size for duplicate rules:", meanDuplicateRuleSize.toFixed(2));
console.log(
    "Weighted mean size for duplicate rules:",
    weightedMeanDuplicateRuleSize.toFixed(2)
);
console.log("Corpus mean prod size", corpusInfo.meanProdSize().toFixed(2));
///////////////////////////
///////////////////////////
///////////////////////////

const numberOfDuplicateRulesNotNonterminals = _.flatten(
    _.map(
        _.flatten(_.map(duplicationData, "duplicateRulesNotNonterminals")),
        "nonterminals"
    )
).length;

const duplicateProductionRulesNotNonterminalPrevalence =
    numberOfDuplicateRulesNotNonterminals / corpusInfo.totalProductionRules();
const filesContainingDuplicateRulesNotNonterminals = duplicationData.filter(
    x => x.duplicateRulesNotNonterminals.length > 0
).length;
const meanDuplicateRuleNotNonterminalSize = _.mean(
    _.map(
        _.flatten(_.map(duplicationData, "duplicateRulesNotNonterminals")),
        "size"
    )
);

console.log();
console.log(
    (duplicateProductionRulesNotNonterminalPrevalence * 100).toFixed(2),
    " of the production rules are a duplicate (not nonterminal) of something else"
);
console.log(
    filesContainingDuplicateRulesNotNonterminals,
    "of the files do contain duplicate rules (not nonterminal). This is ",
    (filesContainingDuplicateRulesNotNonterminals /
        corpusInfo.fileCount() *
        100).toFixed(2)
);
console.log(
    "Mean size for duplicate rules (not nonterminal):",
    meanDuplicateRuleNotNonterminalSize.toFixed(2)
);
console.log();

console.log(
    "Mean for duplicate rules non nonterminals:",
    _.mean(
        _.flatten(_.map(duplicationData, "duplicateRulesNotNonterminals"))
    ).toFixed(2)
);
console.log(
    "Mean for defined subexpressions:",
    _.mean(_.flatten(_.map(duplicationData, "definedSubExpressions"))).toFixed(
        2
    )
);
console.log(
    "Mean for Common subexpression:",
    _.mean(_.flatten(_.map(duplicationData, "commonSubExpressions"))).toFixed(2)
);

const thresholded = function(a, b) {
    return b.filter(x => x >= a);
};

const statsByThreshold = function(x) {
    console.log("\nFor threshold:", x);

    console.log(
        "Files without duplications:",
        duplicationData.filter(
            f =>
                thresholded(x, f.commonSubExpressions).length == 0 &&
                thresholded(x, f.definedSubExpressions).length == 0 &&
                thresholded(x, f.duplicateRules).length == 0
        ).length
    );

    console.log(
        "Files with duplicate rules:",
        duplicationData.filter(f => thresholded(x, f.duplicateRules).length > 0)
            .length
    );

    console.log(
        "Files with duplicate rules:",
        duplicationData.filter(
            f => thresholded(x, f.duplicateRulesNotNonterminals).length > 0
        ).length
    );
    console.log(
        "Files with defined expressions:",
        duplicationData.filter(
            f => thresholded(x, f.definedSubExpressions).length > 0
        ).length
    );
    console.log(
        "Files with common subexpression:",
        duplicationData.filter(
            f => thresholded(x, f.commonSubExpressions).length > 0
        ).length
    );
};
//
statsByThreshold(1);
// statsByThreshold(2);
// statsByThreshold(3);
// statsByThreshold(5);
// statsByThreshold(10);
// statsByThreshold(25);
// statsByThreshold(50);
// statsByThreshold(100);
