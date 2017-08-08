const naming = require("../../output/naming").files;
const allClasses = require("../../output/naming").classes;

const table = require("../latex-table");
const _ = require("lodash");
const total = naming.length;
const overallConsistent = naming.filter(x => x.overall != "unknown()");

function asName(x) {
    return _.capitalize(
        x.replace("()", "").replace(/[A-Z]/g, x => " " + x.toLowerCase())
    );
}
const examples = {
    "camelCased()": "StartingWordsWithUppercase",
    "mixedCased()": "lowerAndUppercase",
    "undecided()": "some\\_Random/things-MIXED",
    "lowerCased()": "likethis",
    "lowerCasedHyphenedWithAttributes()": "something.and-a-property",
    "upperCased()": "VERYLOUD",
    "upperCasedHyphened()": "CONNECTED-WITH-HYPHEN",
    "mixedCasedHyphened()": "WITH-hyphen",
    "lowerCasedUnderscored()": "like\\_so"
};

const overallGroups = _.groupBy(_.map(overallConsistent, "overall"), x => x);
rows = Object.keys(overallGroups).map(x => {
    return [asName(x), examples[x] || "TODO " + x, overallGroups[x].length];
});

console.log(
    table(
        ["Style", "Example", "Occurences"],
        _.reverse(_.sortBy(rows, x => x[2])),
        {
            label: "naming-overall-style",
            caption: "Distribution of naming convention styles"
        }
    )
);
