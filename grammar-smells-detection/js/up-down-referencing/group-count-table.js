const referenceInfo = require("../../output/reference-info");
const base = require("../base");
const allGroups = require("../groups").allGroups;
const locGroupDict = require("../groups").locGroupDict;
const _ = require("lodash");

const total = referenceInfo.length;
const ups = referenceInfo.filter(x => x.dir == "UP").length;
const downs = referenceInfo.filter(x => x.dir == "DOWN").length;
const evens = referenceInfo.filter(x => x.dir == "EVEN").length;

const rows = [
    ["Up referencing", ups + "(" + base.perc(ups, total) + ")", ups],
    ["Down referencing", downs + "(" + base.perc(downs, total) + ")", downs],
    ["Even referencing", evens + "(" + base.perc(evens, total) + ")", evens]
];

const x = require("../latex-table")(
    null,
    _.map(_.reverse(_.orderBy(rows, "2")), x => _.take(x, 2)),
    {
        caption: "Number of grammars per referencing direction",
        label: "up-down-referencing-group-size"
    }
);
console.log(x);
