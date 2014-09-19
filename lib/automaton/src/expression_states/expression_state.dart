part of peg.automaton.expression_states;

class ExpressionState {
  ExpressionStates emptyTransition = new ExpressionStates();

  Expression expression;

  final int id;

  Set<Expression> inputExpressions = new Set<Expression>();

  Set<Expression> outputExpressions = new Set<Expression>();

  SparseList<ExpressionStates> symbolTransitions = new SparseList<ExpressionStates>();

  SparseList<ExpressionStates> unreachableTransitions = new SparseList<ExpressionStates>();

  ExpressionState(this.id, this.expression);

  int get hashCode {
    return id.hashCode;
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    var length = symbolTransitions.length;
    if (other is ExpressionState) {
      if (expression == null) {
        return false;
      }

      return id == other.id;
    }

    return false;
  }

  void addEmptyTransition(ExpressionState state) {
    emptyTransition.add(state);
  }

  void addTransition(RangeList range, ExpressionState state) {
    SparseList<ExpressionStates> transitions;
    if (emptyTransition.length == 0) {
      transitions = this.symbolTransitions;
    } else {
      transitions = unreachableTransitions;
    }

    var groups = transitions.getAlignedGroups(range);
    for (var group in groups) {
      var states = group.key;
      if (states == null) {
        states = new ExpressionStates();
      } else {
        states = new ExpressionStates(states);
      }

      states.add(state);
      group = new GroupedRangeList<ExpressionStates>(group.start, group.end, states);
      symbolTransitions.addGroup(group);
    }
  }

  toString() {
    return "$expression";
  }
}
