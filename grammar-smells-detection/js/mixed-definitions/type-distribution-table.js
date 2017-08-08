const latexTable = require("../latex-table");
const mixedDefinitions = require("../../output/mixed-definitions");
const base = require("../base");

const totals = mixedDefinitions.overall.totals;
const sum =
    totals.undecided + totals.zigzags + totals.horizontals + totals.verticals;

const valuePlusPercentage = function(x, t) {
    return x + " (" + base.perc(x, t) + ")";
};
const output = latexTable(
    null,
    [
        ["Undecided", valuePlusPercentage(totals.undecided, sum)],
        ["Horizontals", valuePlusPercentage(totals.horizontals, sum)],
        ["Verticals", valuePlusPercentage(totals.verticals, sum)],
        ["Zig Zags", valuePlusPercentage(totals.zigzags, sum)]
    ],
    {
        label: "mixed-definitions:type-distribution",
        caption: "Distribution of nonterminals over different definition styles"
    }
);

console.log(output);
