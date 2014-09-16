part of peg.grammar_generator;

class MethodFailureGenerator extends TemplateGenerator {
  static const String NAME = "_failure";

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _EXPECTED = GeneralParserClassGenerator.VARIABLE_EXPECTED;

  static const String _FAILURE_POS = GeneralParserClassGenerator.VARIABLE_FAILURE_POS;

  static const String _TOKEN = GeneralParserClassGenerator.VARIABLE_TOKEN;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME([List<String> expected]) {  
  if ($_FAILURE_POS > $_CURSOR) {
    return;
  }
  if ($_CURSOR > $_FAILURE_POS) {    
    $_EXPECTED = [];
   $_FAILURE_POS = $_CURSOR;
  }
  if (_token != null) {
    $_EXPECTED.add($_TOKEN);
  } else if (expected == null) {
    $_EXPECTED.add(null);
  } else {
    $_EXPECTED.addAll(expected);
  }   
}
''';

  MethodFailureGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
