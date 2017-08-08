# Grammar Smells Detection

An artefact that analyses the [Grammar Zoo](slebok.github.io/zoo/) for grammar smells.

### Prerequisites

* Git
* NodeJS >= v6
* Eclipse IDE Neon.3 with the [Rascal MetaProgramming Language Plugin](http://www.rascal-mpl.org/) (v0.8.0.201510231502)

### Dependencies

This work depends on two other repositories:

* GrammarLab \[[GitHub](https://github.com/cwi-swat/grammarlab)\]
* GrammarZoo \[[GitHub](https://github.com/slebok/zoo)\]

### Setup

Run the following two bash scripts:

```
sh setup_zoo.sh
sh setup_grammarlab.sh
npm install
```

With these two scripts you make sure you have the correct files on the correct location on your file system.

### Generating results

In the Eclipse IDE, start a Rascal console and execute the following commands:

```
import Main;
Main::export();
```

This process will execute ten minutes (+/-) and will write the results of the analysis process to the `/output` directory.

The `js` folder includes several scripts to analyse the output further.
