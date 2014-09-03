part of peg.grammar_generator;

class MethodCalculatePosGenerator extends TemplateGenerator {
  static const String NAME = "_calculatePos";

  static const String _COLUMN = ParserClassGenerator.VARIABLE_COLUMN;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _LINE = ParserClassGenerator.VARIABLE_LINE;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

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

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
