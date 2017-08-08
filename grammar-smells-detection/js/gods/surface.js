const sizes = require("../../output/sizes");
const _ = require("lodash");

const normalizeValue = function(v, low, high) {
    return (v - low * 1.0) / (high - low);
};

const surface = function(points) {
    const sorted = _.sortBy(points, 0);
    var total = 0.0;
    for (var i = 0; i < sorted.length - 1; i++) {
        const pointA = sorted[i];
        const pointB = sorted[i + 1];
        const xDiff = pointB[0] - pointA[0];
        const yBase = _.min([pointB[1], pointA[1]]);
        const yDiff = _.max([pointB[1], pointA[1]]) - yBase;

        const res = xDiff * yBase + xDiff * yDiff / 2.0;
        total += res;
    }
    return total;
};
const normalize = function(x) {
    const yMax = _.max(_.map(x, "1"));
    const yMin = _.min(_.map(x, "1"));
    const xMax = _.max(_.map(x, "0"));
    const xMin = _.min(_.map(x, "0"));

    return _.map(x, y => [
        normalizeValue(y[0], xMin, xMax),
        normalizeValue(y[1], yMin, yMax)
    ]);
};
const countGrouped = function(x, range) {
    const g = _.mapValues(_.groupBy(x), "length");

    for (var i = 0; i < range; i++) {
        if (!g[i]) {
            g[i] = 0;
        }
    }
    return _.map(_.toPairs(g), x => [parseInt(x[0]), x[1]]);
};

const allProds = _.flatten(
    _.map(_.flatten(_.map(sizes, "nonterminals")), "prods")
);

const buildPercentages = function(x) {
    const sorted = _.sortBy(x);
    return {
        80: _.take(_.drop(sorted, sorted.length * 0.8), 1)[0],
        90: _.take(_.drop(sorted, sorted.length * 0.9), 1)[0],
        95: _.take(_.drop(sorted, sorted.length * 0.95), 1)[0]
    };
};

const violatesPercentages = function(x, y, count, d) {
    return (
        Object.keys(y).filter(function(k) {
            return y[k] - d > x[k];
        }).length >= count
    );
};
const allSizes = _.sortBy(_.map(allProds, "size"));
const percentages = buildPercentages(allSizes);
console.log(percentages);

const maxValueGroupSizes = _.max(allSizes);

const allSizesCounted = countGrouped(allSizes, maxValueGroupSizes);
const normalSurface = surface(normalize(allSizesCounted));

// console.log(allSizesCounted);
// console.log("Normal surface: ", normalSurface);
const lower = [];
const higher = [];
// sizes;
sizes.filter(function(locationSize) {
    const locProds = _.flatten(_.map(locationSize.nonterminals, "prods"));
    const locSizes = _.sortBy(_.map(locProds, "size"));
    const locPerc = buildPercentages(locSizes);
    const v = violatesPercentages(percentages, locPerc, 2, 10);
    // if (v) {
    //     console.log(locationSize.location);
    //     console.log(v, locPerc);
    // }

    return v;
});
console.log(lower.length);
console.log(higher.length);
