const _ = require("lodash");
module.exports = function(items, prop, options) {
    const step = options.step;

    const total = _.sum(_.map(items, prop));
    const sorted = _.sortBy(items, prop);

    var current = 0;
    var nextStepMarker = 0.0;

    const points = [];
    for (var i = 0; i < sorted.length; i++) {
        const item = sorted[i];
        x = (i + 1) / items.length;
        current += prop(item);
        y = current / total;

        if (x >= nextStepMarker) {
            points.push([x, y]);
            var z = nextStepMarker + step;
            nextStepMarker = parseFloat(z.toFixed(9));
        }
    }

    return points;
};
