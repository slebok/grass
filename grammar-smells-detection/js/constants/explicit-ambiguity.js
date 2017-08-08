const explicitAmbiguity = require("../../output/explicit-ambiguity");
const _ = require("lodash");
const corpusInfo = require("../corpus-info");
const base = require("../base");

const rawFiles = _.filter(explicitAmbiguity, x => x.violations.length > 0);
const rawFileCount = rawFiles.length;

const rawFileViolations = _.flatten(_.map(explicitAmbiguity, "violations"));
const rawFileViolationCount = rawFileViolations.length;

const nonEpsilonFiles = _.filter(
    explicitAmbiguity,
    x => x.violations.filter(y => y[2]).length > 0
);
const nonEpsilonFileCount = nonEpsilonFiles.length;

const nonEpsilonViolations = _.filter(
    _.flatten(_.map(explicitAmbiguity, "violations")),
    "2"
);
const nonEpsilonViolationCount = nonEpsilonViolations.length;

module.exports = {
    "explicit-ambiguity/raw/files": rawFileCount,
    "explicit-ambiguity/raw/violations": rawFileViolationCount,
    "explicit-ambiguity/non-epsilon/files": nonEpsilonFileCount,
    "explicit-ambiguity/non-epsilon/files-perc": base.perc(
        nonEpsilonFileCount,
        corpusInfo.fileCount()
    ),
    "explicit-ambiguity/non-epsilon/violations": nonEpsilonViolationCount,
    "explicit-ambiguity/non-epsilon/violations-perc": base.perc(
        nonEpsilonViolationCount,
        corpusInfo.totalProductionRules()
    )
};
