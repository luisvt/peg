part of peg.frontend_analyzer.frontend_analyzer;

class RepetitionExpressionsResolver extends ExpressionResolver {
  Object visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_REPETITION;
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_REPETITION;
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      expression.flag |= child.flag & Expression.FLAG_REPETITION;
    }

    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.flag |= ruleExpression.flag & Expression.FLAG_REPETITION;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    for (var child in expression.expressions) {
      child.accept(this);
      expression.flag |= child.flag & Expression.FLAG_REPETITION;
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_REPETITION;
    return null;
  }
}
