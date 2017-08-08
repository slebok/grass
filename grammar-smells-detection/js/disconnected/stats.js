const disconnected = require('../../output/disconnected.json');
const _ = require('lodash');

const total = disconnected.length;
const withStart = disconnected.filter(x => x.starts.length > 0).length;
const withTops = disconnected.filter(x => x.tops.length > 0).length;
const noStartsNoTops = disconnected.filter(x => x.tops.length == 0 && x.starts.length == 0).length;

const withDisconnected = _.filter(disconnected, x => x.nonterminals.length > 0);
const withDisconnectedAndTops = _.filter(disconnected, x => x.nonterminals.length > 0 && x.tops.length > 0);
const withDisconnectedAndStarts = _.filter(disconnected, x => x.nonterminals.length > 0 && x.starts.length > 0);
const withDisconnectedTopsAndStarts = _.filter(disconnected, x => x.nonterminals.length > 0 && x.tops.length > 0 && x.starts.length > 0);

console.log("Total:", total);
console.log("With start:", withStart);
console.log("With tops:", withTops);
console.log("No starts and no tops:", noStartsNoTops);
console.log("With disconnected:", withDisconnected.length);
console.log("With disconnected and tops:", withDisconnectedAndTops.length);
console.log("With disconnected and starts:", withDisconnectedAndStarts.length);
console.log("With disconnected, tops and starts:", withDisconnectedTopsAndStarts.length);

console.log(_.take(_.map(_.shuffle(withDisconnectedAndTops), 'location'), 10));
