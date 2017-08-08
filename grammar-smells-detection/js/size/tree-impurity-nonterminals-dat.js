const sizes = require("../../output/sizes");
const _ = require("lodash");
const dataFile = require("../dataFile");
const grammarStats = require("../grammar-stats-util");

const treeImpurityByNonterminals = _.map(sizes, x => [
    x.impurity,
    grammarStats.statForFile(x.location).nonterminals
]);

dataFile.build(["impurity", "nonterminals"], treeImpurityByNonterminals);
