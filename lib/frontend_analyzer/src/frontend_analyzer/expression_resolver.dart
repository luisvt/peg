part of peg.frontend_analyzer.frontend_analyzer;

abstract class ExpressionResolver extends UnifyingExpressionVisitor {
  int level;

  Set<Expression> processed = new Set<Expression>();

  void resolve(List<ProductionRule> rules) {
    level = 0;
    for (var i = 0; i < 2; i++) {
      level = i;
      for (var rule in rules) {
        rule.expression.accept(this);
      }
    }
  }
}
