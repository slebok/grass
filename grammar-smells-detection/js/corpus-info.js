const _ = require("lodash");
const sizes = require("../output/sizes");
const allProds = _.flatten(
    _.map(_.flatten(_.map(sizes, "nonterminals")), "prods")
);
const totalProds = allProds.length;
const files = sizes.length;
const totalNs = _.sum(sizes.map(x => x.nonterminals.length));
const totalDefinedNs = _.sum(
    sizes.map(x => x.nonterminals.filter(n => n.prods.length > 0).length)
);

module.exports = {
    totalNonterminals: function() {
        return totalNs;
    },
    totalDefinedNonterminals: function() {
        return totalDefinedNs;
    },
    totalProductionRules: function() {
        return totalProds;
    },
    fileCount: function() {
        return files;
    },
    meanProdSize: function() {
        return _.mean(_.map(allProds, "size"));
    }
};
