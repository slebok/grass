const referenceInfo = require("../../output/reference-info");
const groups = require("../groups");
const locGroupDict = groups.locGroupDict;
const grammarStatsUtil = require("../grammar-stats-util");

function all() {
    return referenceInfo
        .filter(x => x.dir == "EVEN")
        .filter(x => locGroupDict[x.location] == groups.smallestGroup);
}
module.exports = {
    all: function() {
        return all().length;
    },
    noRefs: function() {
        const noReferenceEvens = all().filter(
            x => grammarStatsUtil.statForFile(x.location).references === 0
        );
        return noReferenceEvens.length;
    }
};
