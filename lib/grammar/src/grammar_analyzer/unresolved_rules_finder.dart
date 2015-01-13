part of peg.grammar.grammar_analyzer;

class UnresolvedRulesFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<RuleExpression>> _result;

  Map<ProductionRule, List<RuleExpression>> find(List<ProductionRule> rules) {
    _result = new Map<ProductionRule, List<RuleExpression>>();
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    return _result;
  }

  Object visitRule(RuleExpression expression) {
    if (expression.rule == null) {
      var owner = expression.owner;
      var list = _result[owner];
      if (list == null) {
        list = new List<RuleExpression>();
        _result[owner] = list;
      }

      list.add(expression);
    }

    return null;
  }
}
