const scatteredNonterminals = require('../../output/single-list-thingy');
const _ = require('lodash');
const locs = require('../locations');

console.log("Total:", scatteredNonterminals.length);
const fileGroups = _.groupBy(scatteredNonterminals, '0');
console.log("Affected files:", Object.keys(fileGroups).length);

Object.keys(fileGroups).forEach(k => {
    console.log("-(", fileGroups[k].length , ")", locs.asUrl(k), _.map(fileGroups[k],'1').join(' '));
})
