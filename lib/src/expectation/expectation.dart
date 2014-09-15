part of peg.expectation;

class Expectation {
  static String getExpectedAsPrintableList(Expression expression) {
    var expected = expression.expected.toList();
    var length = expected.length;
    for (var i = 0; i < length; i++) {
      expected[i] = _toPrintableString(expected[i]);
    }

    return "[${expected.join(", ")}]";
  }

  static Iterable<String> getExpected(ProductionRule productionRule) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    // "null" means unexpected
    // "empty string" used only in subterminals
    var expression = productionRule.expression;
    if (productionRule.isMasterTerminal) {
      var name = productionRule.name;
      var expected = expression.expected;
      if (expected.length == 1) {
        return [expected.first];
      }

      return [name];
    } else if (productionRule.isSlaveTerminal) {
      if (productionRule.directCallers.length == 1) {
        return getExpected(productionRule.directCallers.first);
      }

      return <String>[];
    } else {
      return expression.expected.toList();
    }
  }

  static Iterable<String> getExpectedForAndPredicate(AndPredicateExpression expression) {
    if (expression == null) {
      throw new ArgumentError("expression: $expression");
    }

    return _getExpected(expression.owner, null, expression.expression.expected);
  }

  static Iterable<String> getExpectedForAnyCharacter(AnyCharacterExpression expression) {
    if (expression == null) {
      throw new ArgumentError("expression: $expression");
    }

    return _getExpected(expression.owner, null, [null]);
  }

  static Iterable<String> getExpectedForCharacterClass(CharacterClassExpression expression) {
    if (expression == null) {
      throw new ArgumentError("expression: $expression");
    }

    String token;
    var groups = expression.ranges.groups;
    if (groups.length == 1) {
      var group = groups.first;
      if (group.start == group.end) {
        token = new String.fromCharCode(group.start);
      }
    }

    // TODO: Improve expression.toString() as token representation
    return _getExpected(expression.owner, token, [expression.toString()]);
  }

  static Iterable<String> getExpectedForLiteral(LiteralExpression expression) {
    if (expression == null) {
      throw new ArgumentError("expression: $expression");
    }

    var text = expression.text;
    if (text.isEmpty) {
      return _getExpected(expression.owner, null, [null]);
    } else {
      return _getExpected(expression.owner, text, [text]);
    }
  }

  static Iterable<String> getExpectedForNotPredicate(NotPredicateExpression expression) {
    if (expression == null) {
      throw new ArgumentError("expression: $expression");
    }

    var next = _getNextExpression(expression);
    if (next != null) {
      return next.expected;
    }

    return _getExpected(expression.owner, null, [null]);
  }

  static Iterable<String> _getExpected(ProductionRule productionRule, String token, Iterable<String> expected) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    if (expected == null) {
      throw new ArgumentError("expected: $expected");
    }

    if (productionRule.isMasterTerminal) {
      if (token != null && !token.isEmpty) {
        return [token];
      }

      return productionRule.expected.toList();
    } else if (productionRule.isSlaveTerminal) {
      return const [];
    } else {
      if (expected.isEmpty) {
        throw new StateError("Expected is empty.");
      }

      return expected;
    }
  }

  static Expression _getNextExpression(Expression expression) {
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

  static String _toPrintableString(String string) {
    if (string == null) {
      return "null";
    }

    if (string.isEmpty) {
      return "\"\"";
    }

    return "\"${Utils.toPrintable(string)}\"";
  }
}
