part of string_matching.interpreter_class_generator;

class MethodCalculatePosGenerator extends MethodGenerator {
  static const String NAME = "_calculatePos";

  static const String _COLUMN = GlobalNaming.COLUMN;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _LINE = GlobalNaming.LINE;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null || pos < 0 || pos > $_INPUT_LEN) {
    return;
  }
  $_LINE = 1;
  $_COLUMN = 1;
  for (var i = 0; i < $_INPUT_LEN && i < pos; i++) {
    var c = $_RUNES[i];
    if (c == 13) {
      $_LINE++;
      $_COLUMN = 1;
      if (i + 1 < $_INPUT_LEN && $_RUNES[i + 1] == 10) {
        i++;
      }
    } else if (c == 10) {
      $_LINE++;
      $_COLUMN = 1;
    } else {
      $_COLUMN++;
    }
  }
}
''';

  MethodCalculatePosGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
