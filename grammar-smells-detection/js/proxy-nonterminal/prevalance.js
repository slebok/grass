const redirectingNonterminalsByFile = require("../../output/redirecting-nonterminals-by-file");
const _ = require("lodash");
const gsutil = require("../grammar-stats-util.js");
const base = require("../base");

const pairs = Object.keys(redirectingNonterminalsByFile).map(k => [
    redirectingNonterminalsByFile[k].ns.length,
    gsutil.statForFile(k).nonterminals
]);

const affected = _.sum(_.map(pairs, 0));
const total = _.sum(_.map(pairs, 1));
console.log("Prevalence of redirecting:");
console.log("> Affected nonterminals:", affected);
console.log("> Total nonterminals:", total);
console.log("> Percentage:", base.perc(affected, total));
