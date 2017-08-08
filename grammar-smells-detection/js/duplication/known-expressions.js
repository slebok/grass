const duplication = require("../../output/duplication");
const _ = require("lodash");

const allDefinedSubExpressions = _.flatten(
    duplication.map(x => x.definedSubExpressions.map(y => [x.location, y]))
);

// console.log(allDefinedSubExpressions.length);
// console.log(allDefinedSubExpressions[0]);

duplication[0].definedSubExpressions.forEach(x => {
    console.log(x);
});

console.log(duplication.length);
console.log(duplication.filter(x => x.definedSubExpressions.length > 0).length);
