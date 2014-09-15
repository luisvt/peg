part of peg.frontend_analyzer;

class ExpectedResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.expected.addAll(Expectation.getExpectedForAndPredicate(expression));
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    expression.expected.addAll(Expectation.getExpectedForAnyCharacter(expression));
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    expression.expected.addAll(Expectation.getExpectedForCharacterClass(expression));
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    expression.expected.addAll(Expectation.getExpectedForLiteral(expression));
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    expression.expected.addAll(Expectation.getExpectedForNotPredicate(expression));
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.expected.addAll(child.expected);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      expression.expected.addAll(child.expected);
    }

    var owner = expression.owner;
    var expected = Expectation.getExpected(owner);
    expression.expected.addAll(expected);
    if (expression.parent == null) {
      owner.expected.addAll(expected);
    }

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.expected.addAll(ruleExpression.expected);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var skip = false;
    for (var child in expression.expressions) {
      child.accept(this);
      if (!skip) {
        expression.expected.addAll(child.expected);
        if (!child.isOptional) {
          skip = true;
        }
      }
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    return null;
  }
}
