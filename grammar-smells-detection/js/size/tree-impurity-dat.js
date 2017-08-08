const sizes = require("../../output/sizes");
const _ = require("lodash");
const dataFile = require("../dataFile");
const grammarStats = require("../grammar-stats-util");

const treeImpurity = _.map(
    _.toPairs(_.mapValues(_.groupBy(_.flatMap(sizes, "impurity")), "length")),
    x => [parseFloat(x[0]), x[1]]
);

dataFile.build(["impurity", "grammars"], treeImpurity);
