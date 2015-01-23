part of peg.grammar.grammar_reporter;

class GrammarReporter {
  final Grammar grammar;

  List<ProductionRule> nonterminals = new List<ProductionRule>();

  List<ProductionRule> recursives = new List<ProductionRule>();

  List<ProductionRule> rules = new List<ProductionRule>();

  List<ProductionRule> startingRules = new List<ProductionRule>();

  List<ProductionRule> terminals = new List<ProductionRule>();

  GrammarReporter(this.grammar) {
    if (grammar == null) {
      throw new ArgumentError('grammar: $grammar');
    }

    _prepare();
  }

  void _prepare() {
    for (var rule in grammar.productionRules) {
      rules.add(rule);
      // TODO: Reimplement
      if (rule.isMorpheme || rule.isLexeme) {
        terminals.add(rule);
      } else {
        nonterminals.add(rule);
      }

      if (rule.isRecursive) {
        recursives.add(rule);
      }

      if (rule.directCallers.length == 0) {
        startingRules.add(rule);
      }
    }

    nonterminals.sort((a, b) => a.name.compareTo(b.name));
    recursives.sort((a, b) => a.name.compareTo(b.name));
    rules.sort((a, b) => a.name.compareTo(b.name));
    terminals.sort((a, b) => a.name.compareTo(b.name));
  }
}
