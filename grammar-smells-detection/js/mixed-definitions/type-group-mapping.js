const mixedDefinitions = require("../../output/mixed-definitions");
const _ = require("lodash");
const locGroupDict = require("../groups").locGroupDict;
const allGroups = require("../groups").allGroups;
const fileTypes = Object.keys(mixedDefinitions.overall.file_types);
const table = require('../latex-table');

const allPairs = _.flatMap(fileTypes, t => _.map(allGroups, g => [g, t]));
const pairs = mixedDefinitions.files.map(record => {
    return [locGroupDict[record.location], record.group];
});

const result = allPairs.map(p => [p[0], p[1], pairs.filter(q => _.isEqual(p, q)).length]);
const matrixValue = function(fileType, group) {
    return _.find(result, p => p[0] == group && p[1] == fileType)[2];
}


const headerRow = [""].concat(allGroups);
const otherRows = fileTypes.map(f => [f].concat(allGroups.map(g => matrixValue(f,g))));

const output = table(null, [headerRow].concat(otherRows))
console.log(output);
