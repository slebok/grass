module.exports = {
    prevalence: function() {
        const redirectingNonterminalsByFile = require("../../output/redirecting-nonterminals-by-file");
        const _ = require("lodash");
        const gsutil = require("../grammar-stats-util.js");
        const base = require("../base");

        const pairs = Object.keys(redirectingNonterminalsByFile).map(k => [
            redirectingNonterminalsByFile[k].ns.length,
            gsutil.statForFile(k).nonterminals
        ]);

        const affected = _.sum(_.map(pairs, 0));
        const total = _.sum(_.map(pairs, 1));
        return base.perc(affected, total);
    },
    fileCountWithProxyNs: function() {
        const redirectingNonterminalsByFile = require("../../output/redirecting-nonterminals-by-file");
        const redirectingFiles = Object.keys(
            redirectingNonterminalsByFile
        ).filter(k => redirectingNonterminalsByFile[k].count > 0);
        return redirectingFiles.length;
    }
};
