const massagable = require("../../output/massagable");
const _ = require("lodash");
const grammarStats = require("../grammar-stats-util");

function createMassagableCounters(massagableFiles) {
    return _.mapValues(
        _.groupBy(_.flatten(_.map(massagableFiles, "problems")), x => x),
        "length"
    );
}

console.log("Total files:", massagable.totalFiles);
console.log("Occurences:", massagable.occurences);
console.log();
console.log("Problems:");
const counters = createMassagableCounters(massagable.files);
_.sortBy(
    Object.keys(counters).map(k => {
        return [k, counters[k]];
    }),
    x => x[1] * -1
).forEach(([k, v]) => {
    console.log("-", k, ":", v);
});
console.log();

const printFixable = function(k, p) {
    const keyCounters = createMassagableCounters(
        massagable.files.filter(x =>
            p(grammarStats.statForFile(x.location).facts)
        )
    );
    console.log("Fixable for", k + ":", keyCounters[k] || 0);
};

printFixable("choiceXAndEpsilon()", f => f.containsOptional);
printFixable("choiceEpsilonAndX()", f => f.containsOptional);

printFixable("choiceXPlusAndEpsilon()", f => f.containsStar);
printFixable("choiceEpsilonAndXPlus()", f => f.containsStar);

printFixable("choiceXPlusAndXOptional()", f => f.containsStar);
printFixable("choiceXOptionalAndXPlus()", f => f.containsStar);

printFixable("compositionPlusAfterOptional()", f => f.containsStar);
printFixable("compositionOptionalAfterPlus()", f => f.containsStar);

printFixable("sequenceXAndXStar()", f => f.containsPlus);
printFixable("sequenceXStarAndX()", f => f.containsPlus);
