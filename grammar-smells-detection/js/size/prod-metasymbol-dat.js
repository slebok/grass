const sizes = require("../../output/sizes");
const _ = require("lodash");
const grammarStats = require("../grammar-stats-util");
const dataFile = require("../dataFile");

const flattenedProds = _.flatMap(_.flatMap(sizes, "nonterminals"), "prods");

const prodMetaSymbolCount = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.metasymbols.items.length)),
        "length"
    )
);

dataFile.build(["metasymbols", "prods"], prodMetaSymbolCount);
