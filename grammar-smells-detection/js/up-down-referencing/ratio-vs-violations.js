const gsutil = require("../grammar-stats-util.js");
const referenceInfo = require("../../output/reference-info");
const dataFile = require("../dataFile");
const _ = require("lodash");

const result = referenceInfo.map(function(item) {
    return [
        item.violations.length /
            1.0 /
            gsutil.statForFile(item.location).nonterminals,
        item.ratio
    ];
});

const grouped = _.groupBy(result, i => i);
const resultWithCount = Object.keys(grouped).map(k => {
    return grouped[k][0].concat([grouped[k].length]);
});

dataFile.build(["violations", "ratio", "count"], resultWithCount);

// console.log(result.filter(x => x[0] != 0).filter(x => x[0] + x[1] == 1).length);
// console.log(result.filter(x => x[0] != 0).filter(x => x[0] + x[1] < 1).length);
// console.log(result.filter(x => x[0] != 0).filter(x => x[0] + x[1] > 1).length);
// console.log();
// console.log(result.filter(x => x[0] != 0).filter(x => x[0] < x[1]).length);
// console.log(result.filter(x => x[0] != 0).filter(x => x[0] > x[1]).length);
// console.log(result.filter(x => x[0] == 0).length);
