const referenceInfo = require("../../output/reference-info");
const base = require("../base");
const allGroups = require("../groups").allGroups;
const locGroupDict = require("../groups").locGroupDict;
const _ = require("lodash");

const percentageGroupRows = allGroups.map(group => {
    const filtered = referenceInfo.filter(
        x => locGroupDict[x.location] == group
    );
    const grouped = _.groupBy(filtered, "dir");
    const total = _.sum(_.values(_.mapValues(grouped, "length")));
    const percentages = _.mapValues(grouped, x => base.perc(x.length, total));

    return [
        group,
        percentages.UP || "0.00%",
        percentages.EVEN || "0.00%",
        percentages.DOWN || "0.00%"
    ];
});
const x = require("../latex-table")(
    ["Group", "Up", "Even", "Down"],
    percentageGroupRows,
    {
        label: "up-down-referencing-grouped-table",
        caption:
            "Distribution of grammars over referencing directions in the different groups."
    }
);
console.log(x);
