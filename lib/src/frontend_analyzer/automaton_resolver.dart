part of peg.frontend_analyzer;

class Automaton {
  SparseList<ExpressionState> alphabet;

  ExpressionStates endStates;

  ExpressionState start;

  Automaton() {
    alphabet = new SparseList<ExpressionState>();
    endStates = new ExpressionStates();
  }
}

class AutomatonResolver extends ExpressionResolver {
  Automaton automaton;

  Set<ExpressionState> endStates;

  int id;

  void resolve(List<ProductionRule> rules) {
    var rule = rules.first;
    var expression = rule.expression;
    id = 0;
    var state = _getAssociatedState(expression);
    endStates = new Set<ExpressionState>();
    automaton = new Automaton();
    automaton.start = state;
    endStates.add(state);
    super.resolve([rules.first]);
    automaton.endStates.addAll(endStates);
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    // TODO:
    var state = _getAssociatedState(expression);
    expression.expression.accept(this);
    //
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    if (level == 0) {
      var end = _createState(expression);
      _addSymbols(endStates, end, [Expression.unicodeGroup]);
      endStates = new Set<ExpressionState>();
      endStates.add(end);
    }

    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (level == 0) {
      var end = _createState(expression);
      _addSymbols(endStates, end, expression.ranges.groups);
      endStates = new Set<ExpressionState>();
      endStates.add(end);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (level == 0) {
      var string = expression.text;
      var end = _createState(expression);
      if (string.isEmpty) {
        _addEmpty(endStates, end);
      } else {
        var charCodes = string.codeUnits;
        var c = charCodes[0];
        var length = charCodes.length;
        _addSymbols(endStates, end, [new RangeList(c, c)]);
      }

      endStates = new Set<ExpressionState>();
      endStates.add(end);
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    // TODO:
    expression.expression.accept(this);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    // TODO:
    expression.expression.accept(this);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    // TODO:
    var savedStates = endStates;
    expression.expression.accept(this);
    endStates.addAll(savedStates);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);

    // TODO: clear empty
    // TODO: clear unreachable



    var savedStates = endStates;
    var lastStates = new Set<ExpressionState>();
    for (var child in expression.expressions) {
      endStates = savedStates;
      child.accept(this);
      lastStates.addAll(endStates);
    }

    endStates = lastStates;
    processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    // TODO:
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    for (var child in expression.expressions) {
      child.accept(this);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    // TODO:
    var savedStates = endStates;
    var state = _getAssociatedState(expression);
    var child = expression.expression;
    child.accept(this);
    endStates.addAll(savedStates);
    return null;
  }

  void _addEmpty(Iterable<ExpressionState> endStates, ExpressionState state) {
    for (var endState in endStates) {
      endState.addEmptyTransition(state);
    }
  }

  void _addSymbols(Iterable<ExpressionState> endStates, ExpressionState state, Iterable<RangeList> symbols) {
    for (var endState in endStates) {
      for (var symbol in symbols) {
        endState.addTransition(symbol, state);
      }
    }
  }

  ExpressionState _createState(Expression expression) {
    return new ExpressionState(id++, expression);
  }

  // TODO: remove
  ExpressionState _getAssociatedState(Expression expression) {
    var state = expression.state;
    if (state == null) {
      state = new ExpressionState(id++, expression);
      expression.state = state;
    }

    return state;
  }
}
