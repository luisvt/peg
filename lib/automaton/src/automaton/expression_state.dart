part of peg.automaton.automaton;

class ExpressionState {
  static const int FLAG_EXRESSION_STARTS = 1;

  static const int FLAG_PREDICATE_ENDS = 2;

  ExpressionStates emptyTransition = new ExpressionStates();

  int flag = 0;

  Set<Expression> inputExpressions = new Set<Expression>();

  Set<Expression> outputExpressions = new Set<Expression>();

  SparseList<ExpressionStates> symbolTransitions = new SparseList<ExpressionStates>();

  SparseList<ExpressionStates> unreachableTransitions = new SparseList<ExpressionStates>();

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
}
