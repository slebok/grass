const _ = require("lodash");

module.exports = function() {
    const referenceInfo = require("../../output/reference-info");
    const constantsEvenReferencingSmallestGroup = require("./even-referencing-smallest-group");
    const meanRatio = _.mean(_.map(referenceInfo, "ratio")).toFixed(2);
    const noViolations = _.filter(referenceInfo, x => x.violations.length == 0);

    return {
        "up-down-referencing/even-referencing-smallest-group-no-refs": constantsEvenReferencingSmallestGroup.noRefs(),
        "up-down-referencing/even-referencing-smallest-group": constantsEvenReferencingSmallestGroup.all(),
        "up-down-referencing/mean-ratio": meanRatio,
        "up-down-referencing/no-violations": noViolations.length
    };
};
