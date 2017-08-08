const singleListThingy = require("../../output/single-list-thingy");
const _ = require("lodash");
const locs = require("../locations");
const fileGroups = _.groupBy(singleListThingy, "0");

module.exports = {
    "single-list-thingy/count": singleListThingy.length,
    "single-list-thingy/files": Object.keys(fileGroups).length
};
