part of peg.parser_generation;

class MethodCalculatePosGenerator extends TemplateGenerator {
  static const String NAME = "_calculatePos";

  static const String _COLUMN = GeneralParserClassGenerator.VARIABLE_COLUMN;

  static const String _INPUT = GeneralParserClassGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _LINE = GeneralParserClassGenerator.VARIABLE_LINE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null || pos < 0 || pos > $_INPUT_LEN) {
    return;
  }
  $_LINE = 1;
  $_COLUMN = 1;
  for (var i = 0; i < $_INPUT_LEN && i < pos; i++) {
    var c = $_INPUT[i];
    if (c == 13) {
      $_LINE++;
      $_COLUMN = 1;
      if (i + 1 < $_INPUT_LEN && $_INPUT[i + 1] == 10) {
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
