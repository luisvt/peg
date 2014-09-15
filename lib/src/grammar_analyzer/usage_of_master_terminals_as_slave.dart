part of peg.grammar_analyzer;

class UsageOfMasterTerminalsAsSlaveFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, Iterable<String>> result;

  Map<ProductionRule, Iterable<String>> find(List<ProductionRule> rules) {
    result = <ProductionRule, Set<String>>{};
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    return result;
  }

  visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      if (rule.isMasterTerminal) {
        var owner = expression.owner;
        if (owner.isTerminal) {
          var set = result[owner];
          if (set == null) {
            set = new Set<String>();
            result[owner] = set;
          }

          set.add(rule.name);
        }
      }
    }

    return null;
  }
}
