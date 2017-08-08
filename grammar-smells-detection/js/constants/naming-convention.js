const naming = require("../../output/naming").files;
const _ = require("lodash");
const base = require("../base");
const corpusInfo = require("../corpus-info");

const overallConsistent = naming.filter(x => x.overall != "unknown()");

const overallConsistentCount = overallConsistent.length;
const overallInconsistentCount =
    corpusInfo.fileCount() - overallConsistentCount;

const overallConsistentPerc = base.perc(
    overallConsistentCount,
    corpusInfo.fileCount()
);
const minusTerminalDefinitionsConsistent = naming.filter(
    x => x.minusTerminalDefinitions != "unknown()"
).length;

const terminalDefinitionsConsistent = naming.filter(
    x => x.terminalDefinitions != "unknown()"
).length;

const terminalDefinitionsInconsistent =
    corpusInfo.fileCount() - terminalDefinitionsConsistent;
const terminalDefinitionNotPresent = naming.filter(
    x => x.terminalDefinitions == "notPresent()"
).length;

const terminalDefinitionsInconsistentPerc = base.perc(
    terminalDefinitionsInconsistent,
    corpusInfo.fileCount()
);

const terminalDefinitionsConsistentReal =
    terminalDefinitionsConsistent - terminalDefinitionNotPresent;
const terminalDefinitionsConsistentRealPerc = base.perc(
    terminalDefinitionsConsistentReal,
    corpusInfo.fileCount()
);

module.exports = {
    "naming-convention/inconsistent-files": overallInconsistentCount,
    "naming-convention/consistent-files": overallConsistentCount,
    "naming-convention/consistent-files-perc": overallConsistentPerc,
    "naming-convention/consistent-files-minus-terminal": minusTerminalDefinitionsConsistent,
    "naming-convention/terminal-definition-consistent": terminalDefinitionsConsistentReal,
    "naming-convention/terminal-definition-consistent-perc": terminalDefinitionsConsistentRealPerc,
    "naming-convention/terminal-definition-inconsistent": terminalDefinitionsInconsistent,
    "naming-convention/terminal-definition-inconsistent-perc": terminalDefinitionsInconsistentPerc,
    "naming-convention/terminal-definition-not-present": terminalDefinitionNotPresent
};
