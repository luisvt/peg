part of peg.grammar;

class _RuleExpressionResolver extends SimpleExpressionVisitor {
  Map<String, ProductionRule> _rules;

  void resolve(Map<String, ProductionRule> rules) {
    if (rules == null) {
      throw new ArgumentError("rules: $rules");
    }

    _rules = rules;
    for (var rule in rules.values) {
      rule.expression.accept(this);
    }
  }

  visitRule(RuleExpression expression) {
    expression.rule = _rules[expression.name];
  }
}
