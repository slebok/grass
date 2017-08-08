const travelingFamily = require("../output/traveling-family");
const _ = require("lodash");

const violations = _.flatten(
    _.map(travelingFamily, x => x.violations.map(v => [x.location, v]))
);

console.log("Files:", travelingFamily.length);

console.log(
    "With scatterd",
    violations.filter(x => x[1].type === "scattered-level").length
);
console.log(
    "With mixed",
    violations.filter(x => x[1].type === "mixed-in-level").length
);
console.log(
    "Violated files:",
    travelingFamily.filter(x => x.violations.length > 0).length
);
console.log("Violations:", violations.length);

// travelingFamily.forEach((x, y) => {
//     console.log(y, x.location);
// });

console.log("----");
console.log();

next = _.shuffle(violations)[0];

asElm(next[0], next[1]);

function asElm(l, x) {
    red =
        "redGroup : List String\nredGroup =[" +
        x.level.map(y => JSON.stringify(y)).join(", ") +
        "]\n\n";

    blue =
        "blueGroup : List Int\nblueGroup = " +
        JSON.stringify(x.productions.map(y => y[0])) +
        "\n\n";

    loc =
        "targetUrl : String\ntargetUrl = " +
        JSON.stringify(
            l.replace("|project://grammarsmells/input/zoo", "").replace("|", "")
        ) +
        "\n\n";

    console.log(loc + red + blue);
}
