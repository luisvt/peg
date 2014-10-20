part of peg.frontend_analyzer.frontend_analyzer;

class ExpressionLengthResovler extends ExpressionResolver {
  Object visitAnyCharacter(AnyCharacterExpression expression) {
    expression.maxLength = 1;
    expression.minLength = 1;
    return null;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    _applyFromChild(expression);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    expression.maxLength = 1;
    expression.minLength = 1;
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    var length = expression.text.length;
    expression.maxLength = length;
    expression.minLength = length;
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _applyFromChild(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.maxLength = child.maxLength;
    expression.minLength = 0;
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.maxLength = null;
    expression.minLength = child.minLength;
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    var infinite = false;
    int maxLength;
    var minLength = 0;
    for (var child in expression.expressions) {
      child.accept(this);
      if (minLength == null) {
        minLength = child.minLength;
      } else if (child.minLength != null && minLength > child.minLength) {
        minLength = child.minLength;
      }

      if (!infinite) {
        if (child.maxLength == null) {
          maxLength = null;
          infinite = true;
        } else if (maxLength == null) {
          maxLength = child.maxLength;
        } else if (maxLength < child.maxLength) {
          maxLength = child.maxLength;
        }
      }
    }

    expression.maxLength = maxLength;
    expression.minLength = minLength;
    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.maxLength = ruleExpression.maxLength;
      expression.minLength = ruleExpression.minLength;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var infinite = false;
    int maxLength;
    var minLength = 0;
    for (var child in expression.expressions) {
      child.accept(this);
      if (minLength == null) {
        minLength = child.minLength;
      } else if (child.minLength != null) {
        minLength += child.minLength;
      }

      if (!infinite) {
        if (child.maxLength == null) {
          maxLength = null;
          infinite = true;
        } else if (maxLength == null) {
          maxLength = child.maxLength;
        } else {
          maxLength += child.maxLength;
        }
      }
    }

    expression.maxLength = maxLength;
    expression.minLength = minLength;
    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.maxLength = null;
    expression.minLength = 0;
    return null;
  }

  Object _applyFromChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.maxLength = child.maxLength;
    expression.minLength = child.minLength;
    return null;
  }
}
