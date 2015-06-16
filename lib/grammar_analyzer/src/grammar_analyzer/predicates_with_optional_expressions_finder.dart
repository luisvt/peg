part of peg.grammar_analyzer.grammar_analyzer;

class PredicatesWithOptionalExpressionsFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<Expression>> result;

  ProductionRule _rule;

  Map<ProductionRule, List<Expression>> find(List<ProductionRule> rules) {
    result = new Map<ProductionRule, List<Expression>>();
    for (var rule in rules) {
      _rule = rule;
      rule.expression.accept(this);
    }

    return result;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    if (expression.expression.isOptional) {
      _addExpression(expression);
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    if (expression.expression.isOptional) {
      _addExpression(expression);
    }

    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    var expressions = expression.expressions;
    for (var child in expressions) {
      child.accept(this);
    }

    return null;
  }

  void _addExpression(Expression expression) {
    var list = result[_rule];
    if (list == null) {
      list = <Expression>[];
      result[_rule] = list;
    }

    list.add(expression);
  }
}
