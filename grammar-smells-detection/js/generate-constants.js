const constants = require("../output/constants");
const _ = require("lodash");

const upDownReferencing = require("./constants/up-down-referencing")(constants);
Object.keys(upDownReferencing).forEach(k => {
    constants[k] = upDownReferencing[k];
});

const constansProxyNonterminals = require("./constants/proxy-nonterminals");
constants[
    "proxy-nonterminals/prevalence"
] = constansProxyNonterminals.prevalence();
constants[
    "proxy-nonterminal/file-count-containing"
] = constansProxyNonterminals.fileCountWithProxyNs();

const constantsMixedDefinitions = require("./constants/mixed-definitions");
Object.keys(constantsMixedDefinitions).forEach(k => {
    constants[k] = constantsMixedDefinitions[k];
});

const improperResponsibility = require("./constants/improper-responsibility");
Object.keys(improperResponsibility).forEach(k => {
    constants[k] = improperResponsibility[k];
});

const namingConvention = require("./constants/naming-convention");
Object.keys(namingConvention).forEach(k => {
    constants[k] = namingConvention[k];
});

const disconnected = require("./constants/disconnected");
Object.keys(disconnected).forEach(k => {
    constants[k] = disconnected[k];
});
const massagable = require("./constants/massagable");
Object.keys(massagable).forEach(k => {
    constants[k] = massagable[k];
});
const scattered = require("./constants/scattered-nonterminals");
Object.keys(scattered).forEach(k => {
    constants[k] = scattered[k];
});
const singleListThingy = require("./constants/single-list-thingy");
Object.keys(singleListThingy).forEach(k => {
    constants[k] = singleListThingy[k];
});
const legacyStructures = require("./constants/legacy-structures");
Object.keys(legacyStructures).forEach(k => {
    constants[k] = legacyStructures[k];
});
const explicitAmbiguity = require("./constants/explicit-ambiguity");
Object.keys(explicitAmbiguity).forEach(k => {
    constants[k] = explicitAmbiguity[k];
});
const multiTops = require("./constants/multi-tops");
Object.keys(multiTops).forEach(k => {
    constants[k] = multiTops[k];
});

const duplication = require("./constants/duplication");
Object.keys(duplication).forEach(k => {
    constants[k] = duplication[k];
});

const smallAbstractions = require("./constants/small-abstractions");
Object.keys(smallAbstractions).forEach(k => {
    constants[k] = smallAbstractions[k];
});

const travelingFamily = require("./constants/traveling-family");
Object.keys(travelingFamily).forEach(k => {
    constants[k] = travelingFamily[k];
});

const genLatexLookupFun = function(name, kvs) {
    const header = [
        "\\newcommand{\\" + name + "}[1]{%",
        "    \\IfEqCase{#1}{%"
    ];

    const body = _.map(_.toPairs(kvs), ([k, v]) => {
        return "        {" + k + "}{" + v.toString().replace("%", "\\%") + "}%";
    });

    const footer = [
        "    }[\\PackageError{thesisfact}{Undefined option to " +
            name +
            ": #1}{}]%",
        "}%"
    ];

    return header.concat(body).concat(footer).join("\n");
};

const output = genLatexLookupFun("genthesisfact", constants);
console.log(output);
