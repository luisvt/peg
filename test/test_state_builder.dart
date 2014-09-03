import "package:peg/state_machine_generator.dart";

void main() {
  var lines = _template.split("\n");
  var builder = new StateMethodBuilder();
  var helper = new Helper();
  var states = builder.build(lines, helper);
  for (var lines in states) {
    print("=============");
    print(lines.join("\n"));
  }
}

const String SEPARATOR = "#STATE#";

final String _template = '''
0
$SEPARATOR
1
$SEPARATOR
2
$SEPARATOR
3''';

class Helper implements StateMethodBuilderHelper {
  String get separator => SEPARATOR;

  List<String> onEnd(int index, int count) {
    if(index == count - 1) {
      return ["leave"];
    } else {
      return ["end $index"];
    }
  }

  List<String> onStart(int index, int count) {
    if(index == 0) {
      return ["enter"];
    } else {
      return ["start $index"];
    }
  }
}
