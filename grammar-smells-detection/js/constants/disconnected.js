const disconnected = require("../../output/disconnected.json");
const _ = require("lodash");
const base = require("../base");

const total = disconnected.length;
const withStart = disconnected.filter(x => x.starts.length > 0).length;
const withTops = disconnected.filter(x => x.tops.length > 0).length;
const noStartsNoTops = disconnected.filter(
    x => x.tops.length == 0 && x.starts.length == 0
).length;

const withDisconnected = _.filter(disconnected, x => x.nonterminals.length > 0);
const withDisconnectedAndTops = _.filter(
    disconnected,
    x => x.nonterminals.length > 0 && x.tops.length > 0
);
const withDisconnectedAndStarts = _.filter(
    disconnected,
    x => x.nonterminals.length > 0 && x.starts.length > 0
);
const withDisconnectedTopsAndStarts = _.filter(
    disconnected,
    x => x.nonterminals.length > 0 && x.tops.length > 0 && x.starts.length > 0
);

module.exports = {
    "disconnected/disconnected-total": withDisconnected.length,
    "disconnected/disconnected-total-perc": base.perc(
        withDisconnected.length,
        total
    ),
    "disconnected/disconnected-tops-total": withDisconnectedAndTops.length,
    "disconnected/disconnected-no-entry-total": noStartsNoTops,
    "disconnected/disconnected-no-entry-total-perc": base.perc(
        noStartsNoTops,
        total
    ),

    "disconnected/disconnected-tops-total-perc": base.perc(
        withDisconnectedAndTops.length,
        total
    ),
    "disconnected/disconnected-starts-total": withDisconnectedAndStarts.length,
    "disconnected/disconnected-tops-and-starts-total":
        withDisconnectedTopsAndStarts.length,
    "disconnected/grammars-with-start-perc": base.perc(withStart, total)
};
