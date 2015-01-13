part of peg.grammar_analyzer.grammar_analyzer;

class StartingRulesFinder {
  List<ProductionRule> find(List<ProductionRule> rules) {
    var result = new List<ProductionRule>();
    for (var rule in rules) {
      if (rule.isStartingRule) {
        result.add(rule);
      }
    }

    return result;
  }
}
