part of peg.frontend_analyzer.frontend_analyzer;

class ExpressionLengthResovler extends ExpressionResolver {
  Object visitAnyCharacter(AnyCharacterExpression expression) {
    expression.length = 1;
    return null;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    _applyFromChild(expression);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    expression.length = 1;
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    expression.length = expression.text.length;
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _applyFromChild(expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    var fail = false;
    int length;
    for (var child in expression.expressions) {
      child.accept(this);

      if (!fail) {
        if (child.length == null) {
          length = null;
          fail = true;
        } else if (length == null) {
          length = child.length;
        } else if (length != child.length) {
          length = null;
          fail = true;
        }
      }
    }

    expression.length = length;
    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.length = ruleExpression.length;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var fail = false;
    var length = 0;
    for (var child in expression.expressions) {
      child.accept(this);
      if (!fail) {
        if (child.length == null) {
          length = null;
          fail = true;
        } else {
          length += child.length;
        }
      }
    }

    expression.length = length;
    return null;
  }

  Object _applyFromChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.length = child.length;
    return null;
  }
}
