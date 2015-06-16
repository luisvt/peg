part of peg.frontend_analyzer.frontend_analyzer;

class ExpressionMatchesEofResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.text.isEmpty) {
      expression.flag |= Expression.FLAG_CAN_MATCH_EOF;
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.flag |= Expression.FLAG_CAN_MATCH_EOF;
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.flag |= Expression.FLAG_CAN_MATCH_EOF;
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      _applyData(child, expression);
    }

    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.flag |= rule.expression.flag & Expression.FLAG_CAN_MATCH_EOF;
      _applyData(ruleExpression, expression);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var skip = false;
    for (var child in expression.expressions) {
      child.accept(this);
      if (!skip) {
        _applyData(child, expression);
        if (child.canMatchEof) {
          skip = true;
        }
      }
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.flag |= Expression.FLAG_CAN_MATCH_EOF;
    return null;
  }

  Object _visitChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    _applyData(child, expression);
    return null;
  }

  Object _applyData(Expression from, Expression to) {
    if (from.canMatchEof) {
      to.flag |= Expression.FLAG_CAN_MATCH_EOF;
    }

    return null;
  }
}
