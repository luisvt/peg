part of peg.parser_generators.parser_class_generator;

class MethodFailureGenerator extends DeclarationGenerator {
  static const String NAME = "_failure";

  static const int _FLAG_TOKEN_VALUE = ParserClassGenerator.FLAG_TOKEN_VALUE;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _ERRORS = ParserClassGenerator.ERRORS;

  static const String _EXPECTED = ParserClassGenerator.EXPECTED;

  static const String _FAILURE_POS = ParserClassGenerator.FAILURE_POS;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_ALIASES = ParserClassGenerator.TOKEN_ALIASES;

  static const String _TOKEN_FLAGS = ParserClassGenerator.TOKEN_FLAGS;

  static const String _TOKEN_NAMES = ParserClassGenerator.TOKEN_NAMES;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TYPE_MALFORMED = ParserErrorClassGenerator.TYPE_MALFORMED;

  static const String _TYPE_UNTERMINATED = ParserErrorClassGenerator.TYPE_UNTERMINATED;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME([List<String> expected]) {  
  if ($_FAILURE_POS > $_CURSOR) {
    return;
  }
  if ($_FAILURE_POS < $_CURSOR) {    
    $_EXPECTED = [];
   $_FAILURE_POS = $_CURSOR;
  }
  if ($_TOKEN != null) {
    var alias = $_TOKEN_ALIASES[$_TOKEN];
    var flag = $_TOKEN_FLAGS[$_TOKEN];
    var name = $_TOKEN_NAMES[$_TOKEN];
    if ($_FAILURE_POS > $_TOKEN_START && $_FAILURE_POS == $_INPUT_LEN && (flag & $_FLAG_TOKEN_VALUE) != 0) {             
      var message = "Unterminated '\$name'";
      $_ERRORS.add(new {{ERROR_CLASS}}({{ERROR_CLASS}}.$_TYPE_UNTERMINATED, $_FAILURE_POS, $_TOKEN_START, message));
      $_EXPECTED.addAll(expected);            
    } else if ($_FAILURE_POS > $_TOKEN_START && (flag & $_FLAG_TOKEN_VALUE) != 0) {             
      var message = "Malformed '\$name'";
      $_ERRORS.add(new {{ERROR_CLASS}}({{ERROR_CLASS}}.$_TYPE_MALFORMED, $_FAILURE_POS, $_TOKEN_START, message));
      $_EXPECTED.addAll(expected);            
    } else {
      $_EXPECTED.add(alias);
    }            
  } else if (expected == null) {
    $_EXPECTED.add(null);
  } else {
    $_EXPECTED.addAll(expected);
  }   
}
''';

  final ParserClassGenerator parserClassGenerator;

  MethodFailureGenerator(this.parserClassGenerator) {
    if (parserClassGenerator == null) {
      throw new ArgumentError("parserClassGenerator: $parserClassGenerator");
    }

    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var parserName = parserClassGenerator.name;
    var errorClass = ParserErrorClassGenerator.getName(parserName);
    block.assign("ERROR_CLASS", errorClass);
    return block.process();
  }
}
