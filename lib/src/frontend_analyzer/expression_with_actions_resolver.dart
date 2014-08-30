part of peg.frontend_analyzer;

class ExpressionWithActionsResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _visitChild(expression, expression.expression);
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    if (expression.level == 0) {
      _testExpression(expression);
    }

    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (expression.level == 0) {
      _testExpression(expression);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.level == 0) {
      _testExpression(expression);
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _visitChild(expression, expression.expression);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _visitChild(expression, expression.expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    _visitChild(expression, expression.expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      _visitChild(expression, child);
    }

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      _visitChild(expression, ruleExpression);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var skip = false;
    for (var child in expression.expressions) {
      _visitChild(expression, child);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    _visitChild(expression, expression.expression);
    return null;
  }

  void _testExpression(Expression expression) {
    var action = expression.action;
    if (action != null) {
      expression.flag |= Expression.FLAG_HAS_ACTIONS;
    }
  }

  void _visitChild(Expression parent, Expression child) {
    child.accept(this);
    if (child.hasActions || parent.action != null) {
      parent.flag |= Expression.FLAG_HAS_ACTIONS;
    }
  }
}
