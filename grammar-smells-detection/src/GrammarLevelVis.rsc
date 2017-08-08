module GrammarLevelVis

import vis::Figure;
import vis::Render;
import GrammarInformation;
import IO;
import Set;
import List;

str nodeId(set[str] xs)  {
	list[str] ys = sort(toList(xs));
	return "<ys>";
}

str nodeName(set[str] p) = "<getOneFrom(p)> (<size(p)>)";
//str nodeName(set[str] p) = " <getOneFrom(p)> ";

void foo(loc l) {
	gInfo = GrammarInformation::build(l);
	languageLevels(parts, levelRel) = gInfo.d@levels;
	
	iprintln(parts);

	nodes =
		[ box(text(nodeName(p)), id(nodeId(p)) , size(40), fillColor("lightgreen"))
		| p <- parts
		, name := getOneFrom(p)
		];
		
	some = { nodeId(p) | p <- parts };
	other = ( {} | it + { nodeId(x), nodeId(y) } | <x,y> <- levelRel );
	iprintln( some -other );
	
    edges = [ edge(nodeId(x), nodeId(y)) | <x,y> <- levelRel];
    
	render(graph(nodes, edges, hint("layered"), gap(40)));
}