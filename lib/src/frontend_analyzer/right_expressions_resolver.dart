part of peg.frontend_analyzer;

class RightExpressionsResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _processChild(expression);
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _processChild(expression);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _processChild(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    _processChild(expression);
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

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.directRightExpressions.add(ruleExpression);
      expression.allRightExpressions.add(ruleExpression);
      expression.allRightExpressions.addAll(ruleExpression.allRightExpressions);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var length = expressions.length;
    var skip = false;
    for (var i = length - 1; i >= 0; i--) {
      var child = expressions[i];
      child.accept(this);
      if (!skip) {
        _applyData(child, expression);
        if (!child.isOptional) {
          skip = true;
        }
      }
    }

    return null;
  }


  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    _processChild(expression);
    return null;
  }

  Object _applyData(Expression from, Expression to) {
    to.directRightExpressions.add(from);
    // TODO: to.directRightExpressions.addAll(from.directRightExpressions);
    // to.directRightExpressions.addAll(from.directRightExpressions);
    to.allRightExpressions.add(from);
    to.allRightExpressions.addAll(from.allRightExpressions);
    return null;
  }

  Object _processChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    return _applyData(child, expression);
  }
}
