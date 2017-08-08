const improperResponsibility = require("../../output/improper-responsibility");
const _ = require("lodash");
const gsutil = require("../grammar-stats-util.js");
const base = require("../base");
const corpusInfo = require("../corpus-info");

const naiveAffectedFiles = improperResponsibility.naive.filter(
    item => item.improperExpressions.length > 0
).length;
const implicitAffectedFiles = improperResponsibility.implicit.filter(
    item => item.improperExpressions.length > 0
).length;
const rootLevelImproperFiles = naiveAffectedFiles - implicitAffectedFiles;
const naiveProds = _.sum(
    _.map(improperResponsibility.naive, x => x.improperExpressions.length)
);
const implicitProds = _.sum(
    _.map(improperResponsibility.implicit, x => x.improperExpressions.length)
);

const strictOnlyEpsilon = _.sum(
    _.map(
        improperResponsibility.implicit,
        x => x.improperExpressions.filter(x => x.value == "ε").length
    )
);
module.exports = {
    "improper-responsibility/naive-files": naiveAffectedFiles,
    "improper-responsibility/naive-files-percent": base.perc(
        naiveAffectedFiles,
        corpusInfo.fileCount()
    ),
    "improper-responsibility/strict-files": implicitAffectedFiles,
    "improper-responsibility/strict-files-percent": base.perc(
        implicitAffectedFiles,
        corpusInfo.fileCount()
    ),
    "improper-responsibility/naive-prods": naiveProds,
    "improper-responsibility/naive-prods-percentage": base.perc(
        naiveProds,
        corpusInfo.totalProductionRules()
    ),
    "improper-responsibility/strict-prods": implicitProds,
    "improper-responsibility/strict-prods-percentage": base.perc(
        implicitProds,
        corpusInfo.totalProductionRules()
    ),
    "improper-responsibility/strict-only-epsilon": strictOnlyEpsilon
};
