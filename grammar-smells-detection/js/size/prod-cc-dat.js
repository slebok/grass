const sizes = require("../../output/sizes");
const _ = require("lodash");
const dataFile = require("../dataFile");
const grammarStats = require("../grammar-stats-util");

const flattenedProds = _.flatMap(_.flatMap(sizes, "nonterminals"), "prods");
const prodCC = _.toPairs(
    _.mapValues(
        _.groupBy(_.map(flattenedProds, x => x.complexity.cc)),
        "length"
    )
);

dataFile.build(["cc", "prods"], prodCC);
