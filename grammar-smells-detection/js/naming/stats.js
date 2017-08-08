const naming = require("../../output/naming").files;
const _ = require("lodash");
const total = naming.length;
const overallConsistent = naming.filter(x => x.overall != "unknown()");
const minusTerminalDefinitionsConsistent = naming.filter(
    x => x.minusTerminalDefinitions != "unknown()"
).length;

const terminalDefinitionsConsistent = naming.filter(
    x => x.terminalDefinitions != "unknown()"
).length;

const perc = function(x) {
    const y = x / total * 100.0;
    return "" + y.toFixed(2) + "%";
};
console.log("Total:", total);
console.log(
    "Terminal definitions not present:",
    naming.filter(x => x.terminalDefinitions == "notPresent()").length
);
console.log(
    "Consistent Overall:",
    overallConsistent.length,
    perc(overallConsistent.length)
);
console.log(
    "Consistent Terminal Definitions:",
    terminalDefinitionsConsistent,
    perc(terminalDefinitionsConsistent)
);
console.log(
    "Consistent minus TD:",
    minusTerminalDefinitionsConsistent,
    perc(minusTerminalDefinitionsConsistent)
);

const allUnknown = naming.filter(
    x =>
        x.terminalDefinitions == "unknown()" &&
        x.overall == "unknown()" &&
        x.minusTerminalDefinitions == "unknown()"
);
console.log("All unkown (", allUnknown.length, ")");
allUnknown.forEach(f => {
    console.log(">", f.location);
});
console.log(
    naming.filter(
        x =>
            x.overall != "unknown()" &&
            x.minusTerminalDefinitions == "unknown()"
    )
);

const overallGroups = _.groupBy(_.map(overallConsistent, "overall"), x => x);
console.log("Groups of overall style:");
Object.keys(overallGroups).forEach(x => {
    console.log(">", x, overallGroups[x].length);
});
