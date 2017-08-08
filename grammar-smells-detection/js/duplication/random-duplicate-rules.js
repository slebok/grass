const duplication = require("../../output/duplication");
const _ = require("lodash");

const allRules = _.flatten(
    _.map(duplication, x =>
        _.map(x.duplicateRulesNotNonterminals, y => [x.location, y])
    )
);
_.take(_.shuffle(allRules), 20).forEach(x => {
    console.log("Location:", x[0]);
    console.log(x[1].nonterminals);
    console.log();
});
