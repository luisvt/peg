part of peg.automaton.automaton;

class AutomatonBuilder extends UnifyingExpressionVisitor {
  Map<RuleExpression, ExpressionState> _ruleEndStates;

  ExpressionState _endState;

  Set<RuleExpression> _processed;

  ExpressionState _startState;

  Automaton build(ProductionRule productionRule) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    _startState = new ExpressionState();
    _endState = new ExpressionState();
    _processed = new Set<RuleExpression>();
    _ruleEndStates = <RuleExpression, ExpressionState>{};
    productionRule.expression.accept(this);
    var automaton = new Automaton(_startState, _endState);
    return automaton;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    var lastStates = _startStates;
    expression.expression.accept(this);
    for (var state in _startStates) {
      state.flag |= ExpressionState.FLAG_PREDICATE_ENDS;
    }

    // TODO:

    _startStates = lastStates;
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    _startState.flag |= ExpressionState.FLAG_EXRESSION_STARTS;
    _endState = _addTransition2(_startState, _endState, <RangeList>[Expression.unicodeGroup]);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    _startState.flag |= ExpressionState.FLAG_EXRESSION_STARTS;
    _endState = _addTransition2(_startState, _endState, expression.ranges.groups);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    var text = expression.text;
    if (text.isEmpty) {
      _startState.flag |= ExpressionState.FLAG_EXRESSION_STARTS;
      _endState = _addEmptyTransition2(_startState, _endState);
    } else {
      var codePoints = toRunes(text);
      var length = codePoints.length;
      ExpressionState end;
      var start = _startState;
      for (var i = 0; i < length; i++) {
        var codePoint = codePoints[i];
        if (i == 0) {
          start.flag |= ExpressionState.FLAG_EXRESSION_STARTS;
        }

        if (i == length - 1) {
          end = _endState;
        } else {
          end = null;
        }

        _endState = _addTransition2(start, end, <RangeList>[new RangeList(codePoint, codePoint)]);
        start = _endState;
      }
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    var endState = _endState;
    _endState = null;
    expression.expression.accept(this);
    // _endState.flag |= FAILED


    state.flag |= ExpressionState.FLAG_PREDICATE_ENDS;
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    _addTransitions2(_endState, _endState);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    _addEmptyTransition2(_startState, _endState);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    for (var child in expression.expressions) {
      child.accept(this);
    }

    return null;
  }

  Object visitRule(RuleExpression expression) {
    if (_processed.contains(expression)) {
      if (_endState == null) {
        _endState = _ruleEndStates[expression];
      }

      return null;
    }

    _processed.add(expression);
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      if (_endState == null) {
        _endState = new ExpressionState();
      }

      _ruleEndStates[expression] = _endState;
      ruleExpression.accept(this);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var endState = _endState;
    var startState = _startState;
    var expressions = expression.expressions;
    var length = expressions.length;
    _endState = null;
    for (var i = 0; i < length; i++) {
      if (i == length - 1) {
        _endState = endState;
      } else {
        _endState = null;
      }

      var child = expressions[i];
      child.accept(this);
      _startState = _endState;
    }

    _startState = startState;
    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    _addTransitions2(_endState, _endState);
    _addEmptyTransition2(_startState, _endState);
    return null;
  }

  void _addEmptyTransition(ExpressionStates receivers, ExpressionState state) {
    for (var receiver in receivers) {
      receiver.addEmptyTransition(state);
    }
  }

  ExpressionState _addEmptyTransition2(ExpressionState start, ExpressionState end) {
    if (end == null) {
      end = new ExpressionState();
    }

    start.addEmptyTransition(end);
    return end;
  }

  ExpressionState _addTransition2(ExpressionState start, ExpressionState end, Iterable<RangeList> ranges) {
    if (end == null) {
      end = new ExpressionState();
    }

    for (var range in ranges) {
      start.addTransition(range, end);
    }

    return end;
  }

  void _addTransitions2(ExpressionState start, ExpressionState end) {
    for (var group in start.symbolTransitions.groups) {
      for (var state in group.key) {
        end.addTransition(group, state);
      }
    }

    for (var state in start.emptyTransition) {
      end.addEmptyTransition(state);
    }

    for (var group in start.unreachableTransitions.groups) {
      for (var state in group.key) {
        end.addTransition(group, state);
      }
    }
  }

  void _addTransition(ExpressionStates receivers, Iterable<RangeList> ranges, ExpressionState state) {
    for (var receiver in receivers) {
      for (var range in ranges) {
        receiver.addTransition(range, state);
      }
    }
  }

  void _addTransitions(ExpressionStates receivers, ExpressionStates senders) {
    for (var receiver in receivers) {
      for (var sender in senders) {
        for (var group in sender.symbolTransitions.groups) {
          for (var state in group.key) {
            receiver.addTransition(group, state);
          }
        }
      }
    }

    for (var receiver in receivers) {
      for (var sender in senders) {
        for (var state in sender.emptyTransition) {
          receiver.addEmptyTransition(state);
        }
      }
    }

    for (var receiver in receivers) {
      for (var sender in senders) {
        for (var group in sender.unreachableTransitions.groups) {
          for (var state in group.key) {
            receiver.addTransition(group, state);
          }
        }
      }
    }
  }
}
