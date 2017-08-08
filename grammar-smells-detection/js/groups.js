const grammarStats = require("../output/grammar-stats");

const pairs = grammarStats.map(x => [x.nonterminals, x.location]);
const _ = require("lodash");
const { groupByF } = require("./base.js");
const within = (low, high) => x => low <= x && x <= high;

const nonterminalSizePreds = {
    "1-10": within(1, 10),
    "11-25": within(11, 25),
    "26-50": within(26, 50),
    "51-100": within(51, 100),
    "101-200": within(101, 200),
    "201+": x => x > 200
    // within(201, 500),
    // "501+":
};

const keyedPreds = function(predMap, v) {
    return Object.keys(predMap).filter(x => predMap[x](v))[0];
};

const nonterminalSizeGroup = x => keyedPreds(nonterminalSizePreds, x);
const groups = groupByF(pairs, x => nonterminalSizeGroup(x[0]));

const allGroups = Object.keys(nonterminalSizePreds);
const locGroupDict = {};
Object.keys(groups).forEach(groupKey =>
    groups[groupKey].forEach(value => (locGroupDict[value[1]] = groupKey))
);

module.exports = {
    allGroups: allGroups,
    locGroupDict: locGroupDict,
    sizeOfGroup: function(k) {
        return (groups[k] || []).length;
    },
    forGroup: function(g) {
        return _.map(groups[g], 1);
    },
    smallestGroup: "1-10"
};
