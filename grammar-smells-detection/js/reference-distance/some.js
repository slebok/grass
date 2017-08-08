const refDistance = require("../../output/reference-distance-data");
const base = require("../base");
const _ = require("lodash");
const corpusInfo = require("../corpus-info");

const violations = _.flatten(_.map(refDistance, "violations"));
// console.log("violations", violations);
const violationCount = violations.length;
console.log("violationCount", violationCount);

const violatingFiles = _.filter(refDistance, x => x.violations.length > 0)
    .length;
console.log("violatingFiles", violatingFiles);

const violationCountPerc = base.perc(
    violations.length,
    corpusInfo.totalProductionRules()
);
console.log("violationCountPerc", violationCountPerc);

const violatingFilePerc = base.perc(violatingFiles, corpusInfo.fileCount());
console.log("violatingFilePerc", violatingFilePerc);

module.exports = {
    "reference-distance/files": violatingFiles,
    "reference-distance/files-perc": violatingFilePerc,
    "reference-distance/violations": violationCount,
    "reference-distance/violations-perc": violationCountPerc
};
