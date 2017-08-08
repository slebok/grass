const legacyStructures = require("../../output/legacy-structures-data");
const _ = require("lodash");

const fileCountAll = _.filter(legacyStructures, x => {
    return (x.plus.length > 0) | (x.star.length > 0) | (x.optional.length > 0);
}).length;

const plusFiles = _.filter(legacyStructures, x => {
    return x.plus.length > 0;
});
const nonterminalCountPlus = _.flatten(_.map(plusFiles, "plus")).length;
const fileCountPlus = plusFiles.length;

const starFiles = _.filter(legacyStructures, x => {
    return x.star.length > 0;
});
const nonterminalCountStar = _.flatten(_.map(starFiles, "star")).length;
const fileCountStar = starFiles.length;

const optionalFiles = _.filter(legacyStructures, x => {
    return x.optional.length > 0;
});
const nonterminalCountOptional = _.flatten(_.map(optionalFiles, "optional"))
    .length;
const fileCountOptional = optionalFiles.length;

module.exports = {
    "legacy-structures/files": fileCountAll,
    "legacy-structures/plus/files": fileCountPlus,
    "legacy-structures/plus/nonterminals": nonterminalCountPlus,
    "legacy-structures/star/files": fileCountStar,
    "legacy-structures/star/nonterminals": nonterminalCountStar,
    "legacy-structures/optional/files": fileCountOptional,
    "legacy-structures/optional/nonterminals": nonterminalCountOptional
};

// console.log(module.exports);
// console.log();
// console.log(starFiles);
// console.log();
// console.log(plusFiles);
// console.log();
// _.flatten(
//     _.map(optionalFiles, x => x.optional.map(y => [x.location, y]))
// ).forEach(x => {
//     console.log(x[0], x[1]);
// });
