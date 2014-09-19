part of peg.general_parser.parser_class_generator;

class MethodFailureGenerator extends DeclarationGenerator {
  static const String NAME = "_failure";

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EXPECTED = ParserClassGenerator.EXPECTED;

  static const String _FAILURE_POS = ParserClassGenerator.FAILURE_POS;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

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
  if ($_TOKEN != null) {
    if ($_CURSOR > $_TOKEN_START) {
      // TODO:
      var malformed = true;
    } else if ($_CURSOR == $_INPUT_LEN) {
      // TODO:
      var unterminated = true;
    }
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

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
