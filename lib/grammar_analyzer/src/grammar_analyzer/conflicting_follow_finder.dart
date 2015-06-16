part of peg.grammar_analyzer.grammar_analyzer;

class ConflictingFollowFinder extends UnifyingExpressionVisitor {
  Set<Expression> processed;

  Set<Expression> repetitions;

  void find(List<ProductionRule> rules) {
    processed = new Set<Expression>();
    repetitions = new Set<Expression>();
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    var expressions = <Expression>[];
    for (var expression in repetitions) {
      var parent = expression.parent;
      if (parent is SequenceExpression) {
        var length = parent.expressions.length;
        if (expression.positionInSequence < length - 1) {
          expressions.add(expression);
        }
      }
    }

    for (var expression in expressions) {
      var next = expression.next;
      if (next != null) {
        var rhs = <Expression>[];
        for (var expression in next.allLeftExpressions.toList()) {
          switch (expression.type) {
            case ExpressionTypes.ANY_CHARACTER:
            case ExpressionTypes.CHARACTER_CLASS:
            case ExpressionTypes.LITERAL:
              rhs.add(expression);
              break;
          }
        }

        var builder = new _TreeBuilder();
        builder.build(expression);
      }
    }
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    expression.expression.accept(this);
    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    repetitions.add(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
    }

    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
    }

    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    for (var child in expression.expressions) {
      child.accept(this);
    }

    if (expression.isRepetition) {
      repetitions.add(expression);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    repetitions.add(expression);
    return null;
  }
}

class _AnyCharacterMatcher extends _Matcher {
  AnyCharacterExpression expression;

  _AnyCharacterMatcher(this.expression);

  bool match(Expression expression) {
    throw null;
  }
}

class _CharacterClassMatcher extends _Matcher {
  CharacterClassExpression expression;

  _CharacterClassMatcher(this.expression);

  bool match(Expression expression) {
    throw null;
  }
}

class _LiteralMatcher extends _Matcher {
  LiteralExpression expression;

  _LiteralMatcher(this.expression);

  bool match(Expression expression) {
    throw null;
  }
}

abstract class _Matcher {
  bool last = true;

  Set<_Matcher> next = new Set<_Matcher>();

  void addMather(_Matcher matcher) {
    next.add(matcher);
    last = false;
  }

  bool match(Expression expression);
}

class _TreeBuilder implements ExpressionVisitor {
  Set<_Matcher> _matchers;

  Set<Expression> _processed;

  List<_Matcher> build(Expression expression) {
    _matchers = new Set<_Matcher>();
    _processed = new Set<Expression>();
    expression.accept(this);
    return _matchers.toList();
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    var matcher = new _AnyCharacterMatcher(expression);
    _addMatcher(matcher);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    var matcher = new _CharacterClassMatcher(expression);
    _addMatcher(matcher);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    var matcher = new _LiteralMatcher(expression);
    _addMatcher(matcher);
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  @override
  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    // TODO: implement visitOrderedChoice
    if (_processed.contains(expression)) {
      return null;
    }

    _processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
    }

    throw null;
    return null;
  }

  @override
  Object visitRule(RuleExpression expression) {
    // TODO: implement visitRule
    throw null;
  }

  Object visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var length = expressions.length;
    var matchers = _matchers;
    for (var child in expressions) {
      child.accept(this);
      if (child.isOptional) {
        //
      } else {
        //
      }
    }

    _matchers = matchers;
    throw null;
    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  void _addMatcher(_Matcher matcher) {
    for (var prev in _matchers) {
      prev.addMather(matcher);
    }
  }
}
