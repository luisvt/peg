part of peg.automaton.automaton;

class AutomatonBuilder extends UnifyingExpressionVisitor {
  Map<RuleExpression, ExpressionState> _ruleEndStates;

  ExpressionStates _nextStates;

  ExpressionStates _prevStates;

  Set<RuleExpression> _processed;

  Automaton build(ProductionRule productionRule) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    _nextStates = new ExpressionStates([new ExpressionState()]);
    _prevStates = new ExpressionStates([new ExpressionState()]);
    _processed = new Set<RuleExpression>();
    _ruleEndStates = <RuleExpression, ExpressionState>{};
    productionRule.expression.accept(this);
    var automaton;
    return automaton;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    var text = expression.text;
    if (text.isEmpty) {
      _prevStates = _addEmptyTransition(_prevStates, _nextStates);
    } else {
      var codePoints = toRunes(text);
      var length = codePoints.length;
      ExpressionStates nextStates;
      for (var i = 0; i < length; i++) {
        var codePoint = codePoints[i];
        if (i == 0) {
        }

        if (i == length - 1) {
          nextStates = _nextStates;
        } else {
          nextStates = null;
        }

        _prevStates = _addTransition(_prevStates, nextStates, <RangeList>[new RangeList(codePoint, codePoint)]);
      }
    }

    _nextStates = null;
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    var nextStates = _nextStates;
    var prevStates = _prevStates;
    expression.expression.accept(this);
    if (nextStates == null) {
      _prevStates.addAll(prevStates);
    } else {
      _addEmptyTransition(prevStates, nextStates);
    }

    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (_nextStates == null) {
      _nextStates = new ExpressionStates([new ExpressionState()]);
    }

    var nextStates = _nextStates;
    var prevStates = _prevStates;
    for (var child in expression.expressions) {
      child.accept(this);
      _nextStates = nextStates;
      _prevStates = prevStates;
    }

    return null;
  }

  Object visitRule(RuleExpression expression) {
    if (_processed.contains(expression)) {
      return null;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var length = expressions.length;
    var nextStates = _nextStates;
    for (var i = 0; i < length; i++) {
      var child = expressions[i];
      if (i == length - 1) {
        _nextStates = nextStates;
      } else {
        _nextStates = null;
      }

      child.accept(this);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    var nextStates = _nextStates;
    var prevStates = _prevStates;
    expression.expression.accept(this);
    _nextStates = _prevStates;
    expression.expression.accept(this);



    if (nextStates == null) {
      _prevStates.addAll(prevStates);
    } else {
      _addEmptyTransition(prevStates, nextStates);
    }

    return null;
  }

  ExpressionStates _addEmptyTransition(ExpressionStates prevStates, ExpressionStates nextStates) {
    if (nextStates == null) {
      nextStates = new ExpressionStates([new ExpressionState()]);
    }

    for (var prevState in prevStates) {
      for (var nextState in nextStates) {
        prevState.addEmptyTransition(nextState);
      }
    }

    return nextStates;
  }

  ExpressionStates _addTransition(ExpressionStates prevStates, ExpressionStates nextStates, List<RangeList> ranges) {
    if (nextStates == null) {
      nextStates = new ExpressionStates([new ExpressionState()]);
    }

    for (var prevState in prevStates) {
      for (var range in ranges) {
        for (var nextState in nextStates) {
          prevState.addTransition(range, nextState);
        }
      }
    }

    return nextStates;
  }
}
