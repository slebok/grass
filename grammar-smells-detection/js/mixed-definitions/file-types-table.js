const latexTable = require("../latex-table");
const mixedDefinitions = require("../../output/mixed-definitions");
const _ = require("lodash");
const base = require("../base");
const fileTypes = mixedDefinitions.overall.file_types;

const valuePlusPercentage = function(x, t) {
    return x + " (" + base.perc(x, t) + ")";
};

const fileTypeName = function(k) {
    switch (k) {
        case "":
            return "\\textit{none}";
        case "h":
            return "Horizontal";
        case "v":
            return "Vertical";
        case "z":
            return "ZigZag";
        case "hv":
            return "Horizonal + Vertical";
        case "hz":
            return "Horizonal + ZigZag";
        case "vz":
            return "Vertical + ZigZag";
        case "hvz":
            return "Horizonal + Vertical + ZigZag";
        default:
            return k;
    }
};
const total = _.sum(Object.keys(fileTypes).map(k => fileTypes[k]));

const rows = Object.keys(fileTypes).map(k => {
    return [fileTypeName(k), fileTypes[k], base.perc(fileTypes[k], total)];
});
const output = latexTable(null, rows, {
    label: "mixed-definitions:file-types-table",

    caption:
        "Prevalence of grammars consisting of different production declaration patterns"
});

console.log(output);
