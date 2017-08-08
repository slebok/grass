const _ = require("lodash");
const gsu = require("../grammar-stats-util");
const base = require("../base");
const corpusInfo = require("../corpus-info");

module.exports = {
    ruleStats: function(duplication, key) {
        const totalDuplicationProds = _.sum(
            duplication.map(x => gsu.statForFile(x.location).productions)
        );
        //Full Rules
        const resAllRules = duplication.map(x => {
            const totalProds = _.sum(x[key].map(x => x.nonterminals.length));
            const stat = gsu.statForFile(x.location);
            return [x.location, base.rawPerc(totalProds, stat.productions)];
        });
        const cleanDupRulesFiles = resAllRules.filter(x => x[1] == 0).length;
        const totalProds = _.sum(
            _.map(duplication, x =>
                _.sum(_.map(x[key], y => y.nonterminals.length))
            )
        );

        return {
            filesWithout: cleanDupRulesFiles,
            filesWithoutPerc: base.perc(cleanDupRulesFiles, duplication.length),
            totalProds: totalProds,
            totalProdsPerc: base.perc(totalProds, totalDuplicationProds),
            meanPercentage: base.perc(_.mean(_.map(resAllRules, "1")), 100)
        };
    }
};
