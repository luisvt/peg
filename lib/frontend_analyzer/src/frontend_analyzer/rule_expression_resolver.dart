part of peg.frontend_analyzer.frontend_analyzer;

class RuleExpressionsResolver extends UnifyingExpressionVisitor {
  Map<String, ProductionRule> _rulesMap;

  void resolve(Map<String, ProductionRule> rulesMap) {
    _rulesMap = rulesMap;
    for (var rule in rulesMap.values) {
      rule.expression.accept(this);
    }
  }

  Object visitRule(RuleExpression expression) {
    expression.rule = _rulesMap[expression.name];
    return null;
  }
}
