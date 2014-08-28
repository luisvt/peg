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

  toString() {
    return elements.toList().join(", ");
  }
}

class ExpressionState {
  Expression owner;

  SparseList<ExpressionStates> transitions = new SparseList<ExpressionStates>();

  ExpressionState([this.owner]);

  int get hashCode {
    return owner.hashCode;
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    var length = transitions.length;
    if (other is ExpressionState) {
      if (owner == null) {
        return false;
      }

      return owner == other.owner;
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
    return "owner: $owner";
  }
}

class AutomatonResolver extends ExpressionResolver {
  // TODO: reset each pass
  Set<ExpressionState> lastStates;

  ExpressionState state0;

  AutomatonResolver() {
    lastStates = _newLastStates();
    // TODO: set to first expression
    state0 = new ExpressionState();
    _addLastStates([state0]);
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (level == 0) {
      for (var range in expression.ranges.groups) {
        var state = new ExpressionState(expression);
        _addTransition(range, state);
        _setLastStates([state]);
      }
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
        var state = new ExpressionState(expression);
        _addTransition(new RangeList(c, c), state);
        _setLastStates([state]);
      }
    }

    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    // TODO:
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    var first = _cloneLastStates();
    expression.expression.accept(this);
    _addLastStates(first);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    var first = _cloneLastStates();
    var last = _newLastStates();
    for (var child in expression.expressions) {
      lastStates = _newLastStates(first);
      child.accept(this);
      last.addAll(lastStates);
    }

    _setLastStates(last);
    processed.remove(expression);
    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    for (var child in expression.expressions) {
      // TODO: Insert actions
      child.accept(this);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    // TODO:
    var first = _cloneLastStates();
    expression.expression.accept(this);
    _addTransitions(first, lastStates);
    _addLastStates(first);
    return null;
  }

  void _addTransition(RangeList range, ExpressionState state) {
    for (var last in lastStates) {
      last.addTransition(range, state);
    }
  }

  void _addTransitions(Iterable<ExpressionState> source,
      Iterable<ExpressionState> destination) {
    for (var original in source) {
      for (var transition in original.transitions.groups) {
        for (var state in destination) {
          _addTransition(transition, state);
        }
      }
    }
  }

  void _addLastStates(Iterable<ExpressionState> states) {
    lastStates.addAll(states);
  }

  Set<ExpressionState> _cloneLastStates() {
    var states = new Set<ExpressionState>();
    states.addAll(lastStates);
    return states;
  }

  Set<ExpressionState> _newLastStates([Set<ExpressionState> from]) {
    var states = new Set<ExpressionState>();
    if (from != null) {
      states.addAll(from);
    }

    return states;
  }

  void _setLastStates(Iterable<ExpressionState> states) {
    lastStates = new Set<ExpressionState>();
    lastStates.addAll(states);
  }
}
