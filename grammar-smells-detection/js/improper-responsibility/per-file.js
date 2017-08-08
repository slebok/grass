const improperResponsibility = require("../../output/improper-responsibility");
const _ = require("lodash");
const gsutil = require("../grammar-stats-util.js");
const base = require("../base");
const corpusInfo = require("../corpus-info");

const naiveAffectedFiles = improperResponsibility.naive.filter(
    item => item.improperExpressions.length > 0
).length;
const implicitAffectedFiles = improperResponsibility.implicit.filter(
    item => item.improperExpressions.length > 0
).length;
const rootLevelImproperFiles = naiveAffectedFiles - implicitAffectedFiles;
const naiveProds = _.sum(
    _.map(improperResponsibility.naive, x => x.improperExpressions.length)
);
const implicitProds = _.sum(
    _.map(improperResponsibility.implicit, x => x.improperExpressions.length)
);

console.log(corpusInfo.fileCount(), "total files");
console.log(naiveAffectedFiles, "naive improper responsibility file count");
console.log(implicitAffectedFiles, "improper responsibility file count");
console.log(rootLevelImproperFiles, "files containing improper on root level");
console.log();
console.log(
    naiveProds,
    "naive prods",
    base.perc(naiveProds, corpusInfo.totalProductionRules())
);
console.log(
    implicitProds,
    "implicit prods",
    base.perc(implicitProds, corpusInfo.totalProductionRules())
);

const allImproperProds = _.flatten(
    improperResponsibility.implicit.map(x => {
        return x.improperExpressions.map(y => [x.location, y]);
    })
);
const selection = _.take(_.shuffle(allImproperProds), 10);
console.log(selection);

//
// console.log("Total files:", improperResponsibility.length);
// console.log(
//     "Clean files:",
//     improperResponsibility.filter(x => x.improperExpressions.length == 0).length
// );
//
// console.log(
//     "Mean size:",
//     _.mean(_.flatten(_.map(improperResponsibility, "improperExpressions")))
// );
// console.log(
//     "Total occurrences:",
//     _.sum(_.map(_.map(improperResponsibility, "improperExpressions"), "length"))
// );
// console.log(
//     "Mean occurrences:",
//     _.mean(
//         _.map(_.map(improperResponsibility, "improperExpressions"), "length")
//     )
// );
// console.log(
//     "Mean occurrences in affected files:",
//     _.mean(
//         _.filter(
//             _.map(
//                 _.map(improperResponsibility, "improperExpressions"),
//                 "length"
//             ),
//             x => x != 0
//         )
//     )
// );
//
// const pairs = improperResponsibility.map(x => [
//     x.affectedNonterminals.length,
//     gsutil.statForFile(x.location).nonterminals
// ]);
// const affected = _.sum(_.map(pairs, 0));
// const total = _.sum(_.map(pairs, 1));
// console.log("Prevalence:");
// console.log("> Affected nonterminals:", affected);
// console.log("> Total nonterminals:", total);
// console.log("> Percentage:", base.perc(affected, total));
