part of peg.automaton.automaton;

class Automaton {
  final ExpressionState end;

  final ExpressionState start;

  Automaton(this.start, this.end) {
    if (start == null) {
      throw new ArgumentError("start: $start");
    }

    if (end == null) {
      throw new ArgumentError("end: $end");
    }
  }
}
