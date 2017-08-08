const mixedDefinitions = require("../../output/mixed-definitions");
const _ = require("lodash");
const base = require("../base");

const filesWithZigZag = mixedDefinitions.files.filter(f => f.zigzags > 0)
    .length;
const undecidedFiles = mixedDefinitions.files.filter(
    f => f.horizontals == 0 && f.verticals == 0 && f.zigzags == 0
).length;

const total = _.sum(_.values(mixedDefinitions.overall.totals));
const zz = mixedDefinitions.overall.totals.zigzags;
const percInfectedNs = base.perc(zz, total);

module.exports = {
    "mixed-definitions/file-count": filesWithZigZag,
    "mixed-definitions/undecided-file-count": undecidedFiles,
    "mixed-definitions/percentage-infected-ns": percInfectedNs,
    "mixed-definitions/violating-nonterminals":
        mixedDefinitions.overall.totals.zigzags,
    "mixed-definitions/violating-nonterminals-perc": percInfectedNs
};
