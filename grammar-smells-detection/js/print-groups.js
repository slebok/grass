const groups = require("./groups");
const referenceInfo = require("../output/reference-info");
const _ = require("lodash");

function dirString(x) {
    return _.padEnd(referenceInfo.filter(i => i.location == x)[0].dir, 4);
}
groups.allGroups.forEach(g => {
    console.log();
    console.log(g);
    groups.forGroup(g).forEach(x => {
        console.log("\t", dirString(x), x);
    });
});
