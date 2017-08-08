const sizes = require("../../output/sizes");
const _ = require("lodash");
const grammarStats = require("../grammar-stats-util");
const perc = require("../base").perc;
const flattenedProds = _.flatMap(_.flatMap(sizes, "nonterminals"), "prods");
const prodNonterminalCount = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.nonterminals.items.length)),
        "length"
    )
);

const prodTerminalCount = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.terminals.items.length)),
        "length"
    )
);

const prodMetaSymbolCount = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.metasymbols.items.length)),
        "length"
    )
);

const prodCC = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.complexity.cc)),
        "length"
    )
);

const prodNesting = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.complexity.nesting)),
        "length"
    )
);
const prodNestingAndCC = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.complexity.nestingAndCC)),
        "length"
    )
);

const halsteadOverNs = _.sortBy(
    _.map(sizes, x => [
        grammarStats.statForFile(x.location).nonterminals,
        x.halstead
    ]),
    "0"
);

const recursion = _.mapValues(
    _.groupBy(
        _.map(
            _.flatMap(sizes, "nonterminals"),
            x =>
                x.recursive
                    ? "recursive"
                    : x.mutualRecursive ? "mutual" : "none"
        )
    ),
    "length"
);

const levelSizes = _.toPairs(
    _.mapValues(_.groupBy(_.flatMap(_.flatMap(sizes, "levels"))), "length")
);

const treeImpurity = _.map(
    _.toPairs(
        _.mapValues(
            _.groupBy(_.flatMap(_.flatMap(sizes, "impurity"))),
            "length"
        )
    ),
    x => [parseFloat(x[0]), x[1]]
);

const logPercentageForFirst = function(l) {
    const total = _.sum(_.map(prodNonterminalCount, 1));
    const percentages = [];
    var current = 0;
    l.forEach(x => {
        current = current + x[1];
        console.log(x[0], "->", perc(current, total));
    });
};

console.log("Nonterminals in production rule and number of rules having this");
console.log(prodNonterminalCount);
logPercentageForFirst(prodNonterminalCount);
console.log();

console.log(
    "Terminal count for production rule and number of rules having this"
);
console.log(prodTerminalCount);
logPercentageForFirst(prodTerminalCount);
console.log();

console.log(
    "Metasymbol count for production rule and number of rules having this"
);
console.log(prodMetaSymbolCount);
logPercentageForFirst(prodMetaSymbolCount);
console.log();

console.log("CC value for production rule and number of rules having this");
console.log(prodCC);
logPercentageForFirst(prodCC);
console.log();

console.log(
    "Prod nesting value for production rule and number of rules having this"
);
console.log(prodNesting);
logPercentageForFirst(prodNesting);
console.log();

console.log(
    "Prod nesting and CC value for production rule and number of rules having this"
);
console.log(prodNestingAndCC);
logPercentageForFirst(prodNestingAndCC);
console.log();

console.log(halsteadOverNs);
console.log();

console.log(recursion);
console.log();

console.log(levelSizes);
console.log();

console.log(treeImpurity);
console.log();
