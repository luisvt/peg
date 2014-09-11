part of peg.grammar_generator;

class MethodUnexpectedGenerator extends TemplateGenerator {
  static const String NAME = "unexpected";

  static const String _FAILURE_POS = GeneralParserClassGenerator.VARIABLE_FAILURE_POS;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = GeneralParserClassGenerator.VARIABLE_RUNES;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String get $NAME {
  if ($_FAILURE_POS < 0 || $_FAILURE_POS >= $_INPUT_LEN) {
    return '';    
  }
  return new String.fromCharCode($_RUNES[$_FAILURE_POS]);  
}
''';

  MethodUnexpectedGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
