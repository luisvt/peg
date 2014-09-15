part of peg.frontend_analyzer;

class ExpectedTerminalsResolver extends ExpressionResolver {
  void resolve(List<ProductionRule> rules) {
    super.resolve(rules);
    for (var rule in rules) {
      rule.expected.addAll(_expected(rule));
    }
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.expected.addAll(child.expected);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (expression.level == 0) {
      String terminal = null;
      var groups = expression.ranges.groups;
      if (groups.length == 1) {
        var group = groups.first;
        if (group.start == group.end) {
          terminal = new String.fromCharCode(group.start);
        }
      }

      expression.expected.add(terminal);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.level == 0) {
      var text = expression.text;
      if (!text.isEmpty) {
        expression.expected.add(text);
      } else {
        // TODO:
        expression.expected.add(null);
      }
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    // TODO: Temporarily until NFA not ready
    var next = _getNextExpression(expression);
    if (next != null) {
      expression.expected.addAll(next.expected);
    } else {
      expression.expected.add(null);
    }

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

    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      expression.expected.addAll(_expected(rule));
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

  List<String> _expected(ProductionRule rule) {
    var expression = rule.expression;
    if (rule.isMasterTerminal) {
      var terminal = rule.name;
      var expected = expression.expected;
      if (expected.length == 1) {
        if (expected.first != null) {
          return [expected.first];
        }
      }

      return [terminal];
    } else if (rule.isSlaveTerminal) {
      if (rule.directCallers.length == 1) {
        return _expected(rule.directCallers.first);
      }

      // TODO:
      return <String>[];
    } else {
      return expression.expected.toList();
    }
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
