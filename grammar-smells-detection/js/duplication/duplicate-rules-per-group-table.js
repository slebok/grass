const duplication = require("../../output/duplication");
const _ = require("lodash");
const dupUtil = require("./util");

const locGroupDict = require("../groups").locGroupDict;
const dupGroups = {};

duplication.forEach(x => {
    if (!dupGroups[locGroupDict[x.location]]) {
        dupGroups[locGroupDict[x.location]] = [];
    }
    dupGroups[locGroupDict[x.location]].push(x);
});

const table = require("../latex-table");
const rows = require("../groups").allGroups.map(group => {
    const s = dupUtil.ruleStats(
        dupGroups[group],
        "duplicateRulesNotNonterminals"
    );
    return [group, s.meanPercentage, s.totalProdsPerc, s.filesWithoutPerc];
});

console.log(
    table(
        [
            "Group",
            "%/grammar",
            "% of affected productions",
            "Files without duplication"
        ],
        rows,
        {
            label: "duplication:duplicate-rules-in-groups",
            caption:
                "Distribution of duplicate rules over different grammar sizes"
        }
    )
);
