module Partitions

import Relation;
import IO;


set[set[&T]] partitionForTransitiveClosure(set[&T] full, rel[&T,&T] input) {
	rest = full - (domain(input) + range(input));
	rel[&T,&T] inputClosure = input+;
	set[set[&T]] partitions = {};
	set[&T] done = {};
	
	rel[&T,&T] symetricPairsInputClosure = { <a,b> | <a,b> <- inputClosure, <b,a> in inputClosure};
	  
	for (n <- (domain(inputClosure) + range(inputClosure)), n notin done) {
		set[&T] nextLevel =  { n } + symetricPairsInputClosure[n];
		done += nextLevel;
		partitions = partitions + {nextLevel};
	}
	return partitions + { {n} | n <- rest};
}

test bool partitionForTransitiveClosure1() = partitionForTransitiveClosure({1}, {}) == {{1}};
test bool partitionForTransitiveClosure2() = partitionForTransitiveClosure({1,2},{<1,2>}) == {{1}, {2}};
test bool partitionForTransitiveClosure3() = partitionForTransitiveClosure({1,2,3},{<1,2>, <2,3>, <3,2>}) == {{1}, {2,3}};
test bool partitionForTransitiveClosure4() = partitionForTransitiveClosure({1,2,3,4},{<1,2>, <2,3>, <3,1>}) == {{1, 2, 3}, {4}};
