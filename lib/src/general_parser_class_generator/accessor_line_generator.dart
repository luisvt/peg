part of peg.grammar_generator;

class AccessorLineGenerator extends TemplateGenerator {
  static const String NAME = "line";

  static const String _CALCULATE_POS = MethodCalculatePosGenerator.NAME;

  static const String _FAILURE_POS = GeneralParserClassGenerator.VARIABLE_FAILURE_POS;

  static const String _LINE = GeneralParserClassGenerator.VARIABLE_LINE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
int get $NAME {
  if ($_LINE == -1) {
    $_CALCULATE_POS($_FAILURE_POS);
  }
  return $_LINE;      
}
''';

  AccessorLineGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
