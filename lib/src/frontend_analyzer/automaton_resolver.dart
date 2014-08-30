part of peg.frontend_analyzer;

// TODO: In development
class ExpressionStates {
  LinkedHashSet<ExpressionState> elements =
      new LinkedHashSet<ExpressionState>();

  ExpressionStates([Iterable<ExpressionState> elements]) {
    if (elements != null) {
      this.elements.addAll(elements);
    }
  }

  int get hashCode {
    return elements.length;
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    var length = elements.length;
    if (other is ExpressionStates && other.elements.length == length) {
      var it1 = elements.iterator;
      var it2 = other.elements.iterator;
      while (it1.moveNext()) {
        if (!it2.moveNext()) {
          return false;
        }

        if (it1.current != it2.current) {
          return false;
        }
      }

      if (it2.moveNext()) {
        return false;
      }

      return true;
    }

    return false;
  }

  ExpressionStates clone() {
    return new ExpressionStates(elements);
  }

  void addAll(ExpressionStates states) {
    elements.addAll(states.elements);
  }

  toString() {
    return elements.toList().join(", ");
  }
}

class ExpressionState {
  final int id;

  Expression expression;

  SparseList<ExpressionStates> transitions = new SparseList<ExpressionStates>();

  ExpressionState(this.id, this.expression);

  int get hashCode {
    return id.hashCode;
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    var length = transitions.length;
    if (other is ExpressionState) {
      if (expression == null) {
        return false;
      }

      return id == other.id;
    }

    return false;
  }

  void addTransition(RangeList range, ExpressionState state) {
    var groups = _getAlignedGroups(range);
    for (var group in groups) {
      var states = group.key;
      if (states == null) {
        states = new ExpressionStates();
      } else {
        states = new ExpressionStates(states.elements);
      }

      states.elements.add(state);
      group = new GroupedRangeList<ExpressionStates>(
          group.start,
          group.end,
          states);
      transitions.addGroup(group);
    }
  }

  List<GroupedRangeList<ExpressionStates>> _getAlignedGroups(RangeList range) {
    var groups = transitions.getGroups(range).toList();
    var length = groups.length;
    if (length == 0) {
      return [
          new GroupedRangeList<ExpressionStates>(range.start, range.end, null)];
    }

    var first = groups.first;
    if (range.start > first.start) {
      groups[0] = first.intersection(range);
    } else if (range.start < first.start) {
      var insertion =
          new GroupedRangeList<ExpressionStates>(range.start, first.start - 1, null);
      groups.insert(0, insertion);
    }

    var last = groups.last;
    if (range.end > last.end) {
      var addition =
          new GroupedRangeList<ExpressionStates>(last.end + 1, range.end, null);
      groups.add(addition);
    } else if (range.end < last.end) {
      groups[groups.length - 1] = last.intersection(range);
    }

    return groups;
  }

  toString() {
    return "$expression";
  }
}

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

  Map<Expression, ExpressionState> map;

  void resolve(List<ProductionRule> rules) {
    var rule = rules.first;
    var expression = rule.expression;
    id = 0;
    map = new Map<Expression, ExpressionState>();
    var state = _getAssociatedState(expression);
    endStates = new Set<ExpressionState>();
    automaton = new Automaton();
    automaton.start = state;
    endStates.add(state);
    super.resolve([rules.first]);
    automaton.endStates.elements.addAll(endStates);
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    // TODO:
    expression.expression.accept(this);
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    // TODO:
    if (level == 0) {
      var state = _createState(expression);
      _addSymbols(endStates, state, [Expression.unicodeGroup]);
    }

    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (level == 0) {
      var state = _createState(expression);
      _addSymbols(endStates, state, expression.ranges.groups);
      endStates = new Set<ExpressionState>();
      endStates.add(state);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (level == 0) {
      var string = expression.text;
      if (string.isEmpty) {
        // TODO:
      } else {
        var charCodes = string.codeUnits;
        var c = charCodes[0];
        var length = charCodes.length;
        var state = _createState(expression);
        _addSymbols(endStates, state, [new RangeList(c, c)]);
        endStates = new Set<ExpressionState>();
        endStates.add(state);
      }
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
    expression.expression.accept(this);
    _addTransitions(savedStates, endStates);
    endStates.addAll(savedStates);
    return null;
  }

  void _addTransitions(Iterable<ExpressionState> inputs,
      Iterable<ExpressionState> outputs) {
    for (var output in outputs) {
      for (var transition in output.transitions.groups) {
        for (var input in inputs) {
          input.addTransition(transition, output);
        }
      }
    }
  }

  void _addSymbols(Iterable<ExpressionState> inputs, ExpressionState state,
      Iterable<RangeList> symbols) {
    for (var input in inputs) {
      for (var symbol in symbols) {
        input.addTransition(symbol, state);
      }
    }
  }

  ExpressionState _createState(Expression expression) {
    return new ExpressionState(id++, expression);
  }

  // TODO: remove
  ExpressionState _getAssociatedState(Expression expression) {
    var state = map[expression];
    if (state == null) {
      state = new ExpressionState(id++, expression);
      map[expression] = state;
    }

    return state;
  }
}
