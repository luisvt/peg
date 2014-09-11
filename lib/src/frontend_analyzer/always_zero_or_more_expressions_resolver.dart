part of peg.frontend_analyzer;

class AlwaysZeroOrMoreExpressionsResolver extends ExpressionResolver {
  Object visitOptional(OptionalExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    var ignore = false;
    for (var child in expression.expressions) {
      child.accept(this);
      if (!ignore && child.isAlwaysSuccess) {
        if (child.isAlwaysZeroOrMore) {
          expression.flag |= child.flag & Expression.FLAG_ALWAYS_ZERO_OR_MORE;
        } else {
          ignore = true;
        }        
      }
    }

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.flag |= ruleExpression.flag & Expression.FLAG_ALWAYS_ZERO_OR_MORE;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    for (var child in expressions) {
      child.accept(this);         
    }

    if (expressions.length == 1 && expressions.first.isAlwaysZeroOrMore) {
      expression.flag |= Expression.FLAG_ALWAYS_ZERO_OR_MORE;
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    expression.flag |= Expression.FLAG_ALWAYS_ZERO_OR_MORE;
    return null;
  }

  Object _visitChild(UnaryExpression expression) {
    var child = expression.expression;
    expression.expression.accept(this);
    expression.flag |= child.flag & Expression.FLAG_ALWAYS_ZERO_OR_MORE;
    return null;
  }
}
