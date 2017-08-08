const sizes = require("../../output/sizes");
const _ = require("lodash");
const dataFile = require("../dataFile");
const grammarStats = require("../grammar-stats-util");

const halsteadOverNs = _.sortBy(
    _.map(sizes, x => [
        grammarStats.statForFile(x.location).nonterminals,
        x.halstead
    ]),
    "0"
);

dataFile.build(["nonterminals", "halstead"], halsteadOverNs);
