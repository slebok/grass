const redirectingNonterminalsByFile = require("../../output/redirecting-nonterminals-by-file");
const _ = require("lodash");
const gsutil = require("../grammar-stats-util.js");
const base = require("../base");

const info = Object.keys(redirectingNonterminalsByFile).map(k => [
    redirectingNonterminalsByFile[k].count,
    gsutil.statForFile(k).nonterminals,
    redirectingNonterminalsByFile[k].count / gsutil.statForFile(k).nonterminals,
    k
]);

const highProfile = _.filter(
    _.filter(
        //foo
        _.reverse(_.sortBy(info, "2")),
        x => x[1] > 20 && x[2] >= 0.2
    )
);
// console.log(highProfile);

highProfile.forEach(x => {
    console.log(
        x[3]
            .replace(
                "|project://grammarsmells/input",
                "http://slebok.github.io"
            )
            .replace("grammar.bgf|", "index.html")
    );
});
