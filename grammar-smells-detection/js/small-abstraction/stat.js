const smallAbstractions = require("../../output/small-abstractions");
const _ = require("lodash");
const corpusInfo = require("../corpus-info");
const base = require("../base");

const violatedFiles = smallAbstractions.filter(x => x.nonterminals.length != 0);
const violations = _.flatten(
    _.map(smallAbstractions, x => x.nonterminals.map(y => [x.location, y]))
);

console.log(violatedFiles.length);
console.log(
    base.perc(violations.length, corpusInfo.totalDefinedNonterminals())
);

// console.log(
// _.flatten(
//     _.map(smallAbstractions, x => x.nonterminals.map(y => [x.location, y]))
// );
// );
