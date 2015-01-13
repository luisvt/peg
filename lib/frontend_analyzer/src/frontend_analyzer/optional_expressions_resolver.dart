part of peg.frontend_analyzer.frontend_analyzer;

class OptionalExpressionsResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_IS_OPTIONAL;
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      expression.flag |= child.flag & Expression.FLAG_IS_OPTIONAL;
    }

    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.flag |= ruleExpression.flag & Expression.FLAG_IS_OPTIONAL;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var count = 0;
    var length = 0;
    for (var child in expression.expressions) {
      length++;
      child.accept(this);
      if (child.isOptional) {
        count++;
      }
    }

    if (count == length) {
      expression.flag |= Expression.FLAG_IS_OPTIONAL;
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_IS_OPTIONAL;
    return null;
  }

  Object _visitChild(UnaryExpression expression) {
    var child = expression.expression;
    expression.expression.accept(this);
    expression.flag |= child.flag & Expression.FLAG_IS_OPTIONAL;
    return null;
  }
}
