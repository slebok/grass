const groupByF = function(coll, f) {
    const result = {};
    coll.forEach(i => {
        const k = f(i);
        if (result[k]) {
            result[k].push(i);
        } else {
            result[k] = [i];
        }
    });
    return result;
};

module.exports = {
    groupByF: groupByF,
    perc: function(x, t) {
        if (t == 0) {
            return "0%";
        }
        return (x / t * 100.0).toFixed(2) + "%";
    },
    rawPerc: function(x, t) {
        return x / t * 100.0;
    }
};
