const referenceDistanceData = require("../../output/reference-distance-data.json");
const _ = require("lodash");
const prods = _.flatMap(referenceDistanceData, "prods");
const lorenz = require("../lorenz-curve");

lorenzMax = lorenz(prods, x => x.max, { step: 0.001 });
lorenzMin = lorenz(prods, x => x.min, { step: 0.001 });
lorenzAvg = lorenz(prods, x => x.avg, { step: 0.001 });

function lineArea(points) {
    function lineAreaInner(last, rest) {
        const next = _.head(rest);
        if (!next) {
            return 0.0;
        }
        const deltaX = next[0] - last[0];
        const deltaY = next[1] - last[1];
        const slope = deltaX * deltaY * 0.5;
        const below = Math.min(next[1], last[1]) * deltaX;
        return slope + below + lineAreaInner(next, _.drop(rest, 1));
    }
    return lineAreaInner([0, 0], points);
}

console.log(lineArea(lorenzMax));
console.log(lineArea(lorenzMin));
console.log(lineArea(lorenzAvg));

const maxGiniCoeff = 0.5 / (0.5 + lineArea(lorenzMax));
const minGiniCoeff = 0.5 / (0.5 + lineArea(lorenzMin));
const avgGiniCoeff = 0.5 / (0.5 + lineArea(lorenzAvg));

console.log("Max gini coeff", maxGiniCoeff);
console.log("Min gini coeff", minGiniCoeff);
console.log("Avg gini coeff", avgGiniCoeff);
