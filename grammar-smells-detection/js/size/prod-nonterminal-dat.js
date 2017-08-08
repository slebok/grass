const sizes = require("../../output/sizes");
const _ = require("lodash");
const dataFile = require("../dataFile");
const grammarStats = require("../grammar-stats-util");
const perc = require("../base").perc;

const flattenedProds = _.flatMap(_.flatMap(sizes, "nonterminals"), "prods");
const prodNonterminalCount = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.nonterminals.items.length)),
        "length"
    )
);

dataFile.build(["nonterminals", "prods"], prodNonterminalCount);
