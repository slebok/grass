module.exports = {
    asUrl: function(k) {
        return k
            .replace(
                "|project://grammarsmells/input/",
                "http://slebok.github.io/"
            )
            .replace("/grammar.bgf|", "/index.html");
    }
};
