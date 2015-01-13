part of peg.automaton.automaton;

class ExpressionStates extends Object with ListMixin<ExpressionState> {
  List<ExpressionState> _list;

  Set<ExpressionState> _set;

  ExpressionStates([Iterable<ExpressionState> states]) {
    _list = new List<ExpressionState>();
    _set = new Set<ExpressionState>();

    if (states != null) {
      addAll(states);
    }
  }

  int get hashCode {
    return _list.length;
  }

  int get length => _list.length;

  operator [](int index) {
    return _list[index];
  }

  void operator []=(int index, ExpressionState value) {
    throw new UnsupportedError("[]=");
  }

  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    var length = _list.length;
    if (other is ExpressionStates && other.length == length) {
      var it1 = _list.iterator;
      var it2 = other.iterator;
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
    return new ExpressionStates(_list);
  }

  void add(ExpressionState value) {
    if (!_set.contains(value)) {
      _list.add(value);
      _set.add(value);
    }
  }

  void addAll(Iterable<ExpressionState> iterable) {
    for (var value in iterable) {
      add(value);
    }
  }

  void replaceState(ExpressionState state, [Iterable<ExpressionState> states]) {
    if (!_set.contains(state)) {
      return;
    }

    _set.remove(state);
    var index = _list.indexOf(state);
    _list.removeAt(index);
    for (var state in states) {
      if (!_set.contains(state)) {
        _list.insert(index++, state);
      }
    }
  }

  toString() {
    return _list.toList().join(", ");
  }
}
