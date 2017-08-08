const mixedTops = require("../../output/mixed-tops");
const _ = require("lodash");
const locs = require("../locations");

console.log("Total:", _.flatten(_.map(mixedTops, "1")).length);
console.log("Affected files:", mixedTops.length);
