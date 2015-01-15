part of peg.frontend_analyzer.frontend_analyzer;

class StartingRulesFinder {
  List<ProductionRule> find(List<ProductionRule> rules) {
    var result = new List<ProductionRule>();
    for (var rule in rules) {
      var directCallers = rule.directCallers;
      var length = directCallers.length;
      if (length == 0) {
        rule.isStartingRule = true;
        result.add(rule);
      } else {
        if (length == 1 && directCallers.contains(rule)) {
          rule.isStartingRule = true;
          result.add(rule);
        } else {
          rule.isStartingRule = false;
        }
      }
    }

    return result;
  }
}
