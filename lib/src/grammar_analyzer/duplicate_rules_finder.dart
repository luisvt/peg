part of peg.grammar_analyzer;

class DuplicateRulesFinder {
  List<ProductionRule> find(List<ProductionRule> rules) {
    var result = new List<ProductionRule>();
    var set = new Set<String>();
    for (var rule in rules) {
      var name = rule.name;
      if (set.contains(name)) {
        result.add(rule);
      } else {
        set.add(name);
      }
    }

    return result;
  }
}
