const gsutil = require("../grammar-stats-util.js");
const redirectInfo = require("../../output/redirecting-nonterminals-by-file");
const dataFile = require("../dataFile");

const data = Object.keys(redirectInfo).map(l => {
    const ns = gsutil.statForFile(l).nonterminals;
    return [redirectInfo[l].ns.length / ns, ns];
});

dataFile.build(["prevalence", "ns"], data);
