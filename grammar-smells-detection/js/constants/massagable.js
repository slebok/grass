const _ = require("lodash");
const massagable = require("../../output/massagable");
const grammarStats = require("../grammar-stats-util");
const corpusInfo = require("../corpus-info");
const base = require("../base");

const constants = {};

function createMassagableCounters(massagableFiles) {
    return _.mapValues(
        _.groupBy(_.flatten(_.map(massagableFiles, "problems")), x => x),
        "length"
    );
}
function add(k, v) {
    constants["massagable/" + k] = v;
}

add("total", massagable.totalFiles);
add("total-perc", base.perc(massagable.totalFiles, corpusInfo.fileCount()));
add("occurences", massagable.occurences);
add(
    "occurences-perc",
    base.perc(massagable.occurences, corpusInfo.totalProductionRules())
);

const counters = createMassagableCounters(massagable.files);
Object.keys(counters).forEach(k => {
    add("count-" + k.replace("()", ""), counters[k]);
});

const addFixable = function(k, p) {
    const keyCounters = createMassagableCounters(
        massagable.files.filter(x =>
            p(grammarStats.statForFile(x.location).facts)
        )
    );
    add("fixable-" + k.replace("()", ""), keyCounters[k] || 0);
    add(
        "fixable-perc-" + k.replace("()", ""),
        base.perc(
            keyCounters[k] || 0,
            constants["massagable/count-" + k.replace("()", "")] || 0
        )
    );
};

addFixable("choiceXAndEpsilon()", f => f.containsOptional);
addFixable("choiceEpsilonAndX()", f => f.containsOptional);
addFixable("choiceXPlusAndEpsilon()", f => f.containsStar);
addFixable("choiceEpsilonAndXPlus()", f => f.containsStar);
addFixable("choiceXPlusAndXOptional()", f => f.containsStar);
addFixable("choiceXOptionalAndXPlus()", f => f.containsStar);
addFixable("compositionPlusAfterOptional()", f => f.containsStar);
addFixable("compositionOptionalAfterPlus()", f => f.containsStar);
addFixable("sequenceXAndXStar()", f => f.containsPlus);
addFixable("sequenceXStarAndX()", f => f.containsPlus);

module.exports = constants;
