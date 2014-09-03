part of peg.state_machine_generator;

class StateMethodBuilder {
  List<List<String>> build(List<String> lines, StateMethodBuilderHelper helper) {
    var states = <List<String>>[];
    var current = <String>[];
    states.add(current);
    for (var line in lines) {
      if (line.trimLeft().startsWith(helper.separator)) {
        current = <String>[];
        states.add(current);
      } else {
        current.add(line);
      }
    }

    var length = states.length;
    for (var i = 0; i < length; i++) {
      var state = states[i];
      var lines = helper.onStart(i, length);
      state.insertAll(0, lines);
      lines = helper.onEnd(i, length);
      state.addAll(lines);
    }

    return states;
  }
}

abstract class StateMethodBuilderHelper {
  String get separator;

  List<String> onEnd(int index, int count);

  List<String> onStart(int index, int count);
}
