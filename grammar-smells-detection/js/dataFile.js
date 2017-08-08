module.exports = {
    build: function(cols, values) {
        const header = cols.join(" ");
        const rows = values
            .map(x =>
                x
                    .map(y => {
                        if (typeof y === "number") {
                            return y.toString();
                        } else {
                            return y;
                        }
                    })
                    .join(" ")
            )
            .join("\n");

        const total = header + "\n" + rows;
        console.log(total);
    }
};
