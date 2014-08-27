part of peg.frontend_analyzer;

class ExpectedLexemesResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.expectedLexemes.addAll(child.expectedLexemes);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (expression.level == 0) {
      String lexeme = null;
      var groups = expression.ranges.groups;
      if (groups.length == 1) {
        var group = groups[0];
        if (group.start == group.end) {
          lexeme = new String.fromCharCode(group.start);
        }
      }

      expression.expectedLexemes.add(lexeme);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.level == 0) {
      var text = expression.text;
      if (!text.isEmpty) {
        expression.expectedLexemes.add(text);
      }
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.expectedLexemes.addAll(child.expectedLexemes);
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
      expression.expectedLexemes.addAll(child.expectedLexemes);
    }

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.expectedLexemes.addAll(rule.expression.expectedLexemes);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var skip = false;
    for (var child in expression.expressions) {
      child.accept(this);
      if (!skip) {
        expression.expectedLexemes.addAll(child.expectedLexemes);
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
