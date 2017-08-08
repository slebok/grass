const travelingFamily = require("../../output/traveling-family");
const _ = require("lodash");

const violations = _.flatten(
    _.map(travelingFamily, x => x.violations.map(v => [x.location, v]))
);
const violatingProds = _.flatten(
    travelingFamily.map(x => {
        const pis = _.flatten(
            x.violations.map(v => v.productions.map(p => p[0]))
        );
        return _.intersection(pis);
    })
).length;

module.exports = {
    "traveling-family/affected-files": travelingFamily.filter(
        x => x.violations.length != 0
    ).length,
    "traveling-family/violations": violations.length,
    "traveling-family/violating-prods": violatingProds,
    "traveling-family/mixed-in-level": violations.filter(
        x => x[1].type === "mixed-in-level"
    ).length,
    "traveling-family/scattered-level": violations.filter(
        x => x[1].type === "scattered-level"
    ).length
};
