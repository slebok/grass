module Input

import IO;
import List;

list[loc] extractedGrammarLocationsForFile(loc f) {
	if (isDirectory(f)) {
		if (/extracted$/ := f.path) {
			return [f + "/grammar.bgf"];
		} else {
			return extractedGrammarLocationsInDirInner(f);
		}
	} else {
	 	return [];
	}
}

list[loc] extractedGrammarLocationsInDirInner(loc targetDir) {
	inputFiles = ( [] | it + extractedGrammarLocationsForFile(f) | loc f <- targetDir.ls);
	return inputFiles;
}

list[loc] extractedGrammarLocationsInDir(loc targetDir) {
	inputFiles = extractedGrammarLocationsInDirInner(targetDir);
	//inputFiles = take(1, drop(0, inputFiles));
	return inputFiles;
}

