part of peg.frontend_analyzer.frontend_analyzer;

class LeftExpressionsResolver extends ExpressionResolver {
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
      expression.directLeftExpressions.add(ruleExpression);
      expression.allLeftExpressions.add(ruleExpression);
      expression.allLeftExpressions.addAll(ruleExpression.allLeftExpressions);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var skip = false;
    for (var child in expression.expressions) {
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
    to.directLeftExpressions.add(from);
    // TODO: to.directLeftExpressions.addAll(from.directLeftExpressions);
    //to.directLeftExpressions.addAll(from.directLeftExpressions);
    to.allLeftExpressions.add(from);
    to.allLeftExpressions.addAll(from.allLeftExpressions);
    return null;
  }

  Object _processChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    return _applyData(child, expression);
  }
}
