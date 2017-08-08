const loc = process.argv[2];
const sizes = require("../output/sizes");

if (!loc) {
    console.log("No location provided");
    process.exit();
}

const target = sizes.filter(x => x.location == loc)[0];
console.log(loc);
console.log(target);
