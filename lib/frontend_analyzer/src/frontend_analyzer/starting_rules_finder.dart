part of peg.frontend_analyzer.frontend_analyzer;

class StartingRulesFinder {
  List<ProductionRule> find(List<ProductionRule> rules) {
    var result = new List<ProductionRule>();
    for (var rule in rules) {
      if (rule.directCallers.length == 0) {
        rule.isStartingRule = true;
        result.add(rule);
      } else {
        rule.isStartingRule = false;
      }
    }

    return result;
  }
}
