const grammarStats = require("../../output/grammar-stats");
const table = require("../latex-table");
const groups = require("../groups");

console.log(
    table(
        ["Group", "# of grammars"],
        groups.allGroups.map(x => {
            return [x, groups.sizeOfGroup(x)];
        })
    )
);
