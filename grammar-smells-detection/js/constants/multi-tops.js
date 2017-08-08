const multiTops = require("../../output/multi-tops");
const _ = require("lodash");
const corpusInfo = require("../corpus-info");
const base = require("../base");
const gsu = require("../grammar-stats-util");
const files = multiTops.length;
const noTops = require("../../output/no-tops");

const nonterminalsPerFile = _.mean(
    _.map(multiTops, x => x.nonterminals.length)
);

const fullTops = multiTops
    .filter(x => {
        return (
            gsu.statForFile(x.location).nonterminals == x.nonterminals.length
        );
    })
    .map(x => [x.location, x.nonterminals.length]);

const twoViolations = multiTops.filter(x => x.nonterminals.length <= 2);
const twoViolationsFullyConnected = twoViolations.filter(x => x.connected);

const noTopSingleNonterminalGrammars = noTops
    .filter(x => x.topLevels.length == 1 && x.topLevels[0].length == 1)
    .map(x => x.location);

const noTopsMultiTopLevel = noTops
    .filter(x => x.topLevels.length > 1)
    .map(x => x.location);

module.exports = {
    "multi-tops/files": files,
    "multi-tops/files-perc": base.perc(files, corpusInfo.fileCount()),
    "multi-tops/nonterminals-per-file": nonterminalsPerFile,
    "multi-tops/full-tops": fullTops.length,
    "multi-tops/multi-starts": multiTops.filter(x => x.nonterminals == x.starts)
        .length,
    "multi-tops/fully-connected": multiTops.filter(x => x.connected).length,
    "multi-tops/two-tops": twoViolations.length,
    "multi-tops/two-tops-fully-connected": twoViolationsFullyConnected.length,
    "multi-tops/no-top-file-count": noTops.length,
    "multi-tops/no-top-file-perc": base.perc(
        noTops.length,
        corpusInfo.fileCount()
    ),

    "multi-tops/no-top-single-nonterminal":
        noTopSingleNonterminalGrammars.length,
    "multi-tops/no-tops-positives":
        noTops.length - noTopSingleNonterminalGrammars.length,
    "multi-tops/no-top-multi-level": noTopsMultiTopLevel.length
};

// console.log(twoViolationsFullyConnected);
// twoViolationsFullyConnected.forEach(x => {
//     console.log(
//         x.location,
//         x.location
//             .replace(
//                 "|project://grammarsmells/input",
//                 "http://slebok.github.io"
//             )
//             .replace("grammar.bgf|", "index.html")
//     );
// });
// console.log(twoViolations.filter(x => x.connected).length);
// console.log(module.exports);
// fullTops.forEach(x => {
//     console.log(x[1], x[0]);
// });
