part of peg.frontend_analyzer;

class ExpressionAbleNotConsumeInputResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
    _applyData(expression.expression, expression);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.level == 0) {
      if (expression.text.isEmpty) {
        expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
      }
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
    _applyData(expression.expression, expression);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.flag |= child.flag & Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
    _applyData(child, expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
    _applyData(expression.expression, expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      expression.flag |= child.flag & Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
      _applyData(child, expression);
    }

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.flag |= rule.expression.flag &
          Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
      _applyData(ruleExpression, expression);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var count = 0;
    var length = 0;
    for (var child in expression.expressions) {
      length++;
      child.accept(this);
      if (child.isAbleNotConsumeInput) {
        count++;
      }
    }

    if (count == length) {
      expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
      for (var child in expression.expressions) {
        _applyData(child, expression);
      }
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_ABLE_NOT_CONSUME_INPUT;
    _applyData(expression.expression, expression);
    return null;
  }

  Object _applyData(Expression from, Expression to) {
    to.directAbleNotConsumeInputExpressions.add(from);

        // to.directMayNotConsumeInputExpressions.addAll(from.directLeftExpressions);
    to.allAbleNotConsumeInputExpressions.add(from);
    to.allAbleNotConsumeInputExpressions.addAll(from.allLeftExpressions);
    return null;
  }
}
