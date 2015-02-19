part of peg.grammar_analyzer.grammar_analyzer;

class InfiniteLoopFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, Map<Expression, List<Expression>>> result;

  Map<ProductionRule, Map<Expression, List<Expression>>> find(List<ProductionRule> rules) {
    result = <ProductionRule, Map<Expression, List<Expression>>>{};
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    return result;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    if (expression.expression.isAbleNotConsumeInput) {
      _addExpression(expression);
    }

    return null;
  }

  void _addExpression(ZeroOrMoreExpression expression) {
    var map = result[expression.owner];
    if (map == null) {
      map = <Expression, List<Expression>>{};
      result[expression.owner] = map;
    }

    var list = map[expression];
    if (list == null) {
      list = <Expression>[];
      map[expression] = list;
    }

    var endPoints = new Set<Expression>();
    _findEndPoints(expression, endPoints);
    for (var expression in endPoints) {
      list.add(expression);
    }
  }

  void _findEndPoints(Expression expression, Set<Expression> endPoints) {
    if (!expression.isAbleNotConsumeInput) {
      return;
    }

    for (var expression in expression.directAbleNotConsumeInputExpressions) {
      if (expression.directAbleNotConsumeInputExpressions.isEmpty) {
        if (expression.isAbleNotConsumeInput) {
          endPoints.add(expression);
        }
      } else {
        if (expression is! RuleExpression) {
          _findEndPoints(expression, endPoints);
        } else {
          endPoints.add(expression);
        }
      }
    }
  }
}
