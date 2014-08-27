part of peg.grammar_analyzer;

class UnconventionalNamesFinder {
  List<ProductionRule> find(List<ProductionRule> rules) {
    var result = new List<ProductionRule>();
    for (var rule in rules) {
      if (rule.isTerminal) {
        if (!isUpperCase(rule.name)) {
          result.add(rule);
        }
      }
    }

    return result;
  }
}
