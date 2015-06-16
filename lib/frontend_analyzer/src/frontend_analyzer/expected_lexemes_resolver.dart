part of peg.frontend_analyzer.frontend_analyzer;

class ExpectedLexemesResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    _addExpected(child, expression, true);
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    expression.expectedLexemes.add(null);
    expression.expectedStrings.add(null);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    expression.expectedLexemes.add(null);
    expression.expectedStrings.add(null);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    var text = expression.text;
    if (text.isEmpty) {
      expression.expectedLexemes.add(null);
      expression.expectedStrings.add(null);
    } else {
      expression.expectedLexemes.add(text);
      expression.expectedStrings.add(text);
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    var next = _getNextExpression(expression);
    if (next != null) {
      expression.expectedLexemes.addAll(next.expectedLexemes);
      expression.expectedStrings.addAll(next.expectedStrings);
    } else {
      expression.expectedLexemes.add(null);
      expression.expectedStrings.add(null);
    }

    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    _addExpected(child, expression, true);
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
    _clear(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      _addExpected(child, expression, false);
    }

    var owner = expression.owner;
    if (expression.parent == null) {
      var owner = expression.owner;
      if (owner.isLexeme) {
        var done = false;
        var hasUnexpected = false;
        var expectedLexemes = expression.expectedLexemes;
        var expectedStrings = expression.expectedStrings;
        expectedLexemes.clear();
        for (var string in expectedStrings) {
          if (string == null) {
            hasUnexpected = true;
            break;
          }
        }

        if (expectedStrings.length == 1 && !hasUnexpected) {
          expectedLexemes.add("'${expectedStrings.first}'");
          done = true;
        }

        if (!done) {
          expression.expectedLexemes.add(owner.name);
        }
      }

      owner.expectedLexemes = expression.expectedLexemes;
      owner.expectedStrings = expression.expectedStrings;
    }

    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      _addExpected(ruleExpression, expression, true);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    _clear(expression);
    var skip = false;
    for (var child in expression.expressions) {
      child.accept(this);
      var isPredicate = false;
      switch (child.type) {
        case ExpressionTypes.AND_PREDICATE:
        case ExpressionTypes.NOT_PREDICATE:
          isPredicate = true;
          break;
      }

      if (!skip) {
        _addExpected(child, expression, false);
        if (!(child.isOptional || isPredicate)) {
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

  void _addExpected(Expression source, Expression destination, bool clear) {
    if (clear) {
      _clear(destination);
    }

    destination.expectedLexemes.addAll(source.expectedLexemes);
    destination.expectedStrings.addAll(source.expectedStrings);
  }

  void _clear(Expression expression) {
    //expression.expectedLexemes.clear();
    //expression.expectedStrings.clear();
  }

  Expression _getNextExpression(Expression expression) {
    var parent = expression.parent;
    if (parent is SequenceExpression) {
      var position = expression.positionInSequence;
      if (position < parent.expressions.length - 1) {
        return parent.expressions[position + 1];
      } else if (parent.parent is OrderedChoiceExpression) {
        return _getNextExpression(parent.parent);
      }
    }

    return null;
  }
}
