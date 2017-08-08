const duplicationData = require("../../output/duplication");
const _ = require("lodash");

duplicationData.forEach(file => {
    const greaterThanFive = file.duplicateRulesNotNonterminals.filter(
        x => x.size >= 5
    );
    if (greaterThanFive.length > 0) {
        console.log(file.location);
        console.log(
            _.flatten(greaterThanFive.map(x => x.nonterminals)).map(x => x[0])
        );
        console.log();
    }
});
