const _ = require("lodash");

const buildOpening = function(size) {
    const colDef = " |" + _.range(size).map(_ => "l").join(" | ") + " |";
    return "\\begin{table}[ht!]\n\\centering\n\\begin{tabular}{" + colDef + "}";
};
const buildRow = function(row) {
    return (
        row
            .map(x => x.toString().replace("%", "\\%").replace("#", "\\#"))
            .join(" & ") + " \\\\"
    );
};
const buildTableHeader = function(headers) {
    return (
        "\\hline\n" +
        headers
            .map(x => x.replace("#", "\\#"))
            .map(x => x.replace("%", "\\%"))
            .map(x => "\\textbf{" + x + "}")
            .join(" & ") +
        "\\\\"
    );
};

const latexFuncCall = function(f, value) {
    return "\\" + f + "{" + value + "}";
};
module.exports = function(headers, values, options) {
    options = options || {};

    var size;
    if (headers) {
        size = headers.length;
    } else {
        size = _.max(_.map(values, "length"));
    }
    const rows = values.map(buildRow).map(i => "\\hline\n" + i);

    const tableHeader = headers ? buildTableHeader(headers) : [];

    const footer = _.filter([
        "\\hline",
        "\\end{tabular}",
        options["caption"] && latexFuncCall("caption", options["caption"]),
        options["label"] && latexFuncCall("label", "tbl:" + options["label"]),
        "\\end{table}"
    ]);

    return [buildOpening(size)]
        .concat(tableHeader)
        .concat(rows)
        .concat(footer)
        .join("\n");
};
