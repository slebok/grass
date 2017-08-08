const mixedDefinitions = require("../../output/mixed-definitions");
const _ = require("lodash");
const gsutil = require("../grammar-stats-util.js");
const base = require("../base");

const pairs = mixedDefinitions.files.map(x => [
    x.zigzags,
    gsutil.statForFile(x.location).nonterminals
]);

const affected = _.sum(_.map(pairs, 0));
const total = _.sum(_.map(pairs, 1));
console.log("Prevalence of zigzag:");
console.log("> Affected nonterminals:", affected);
console.log("> Total nonterminals:", total);
console.log("> Percentage:", base.perc(affected, total));
