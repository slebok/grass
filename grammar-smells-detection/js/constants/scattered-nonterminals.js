const scatteredNonterminals = require("../../output/scattered-nonterminals");
const _ = require("lodash");
const locs = require("../locations");
const fileGroups = _.groupBy(scatteredNonterminals, "0");

module.exports = {
    "scattered-nonterminals/file-count": Object.keys(fileGroups).length,
    "scattered-nonterminals/nonterminal-count": scatteredNonterminals.length
};
