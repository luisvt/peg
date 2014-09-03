part of peg.grammar_generator;

class MethodMatchAnyGenerator extends TemplateGenerator {
  static const String NAME = "_matchAny";

  static const String _CH = ParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = ParserClassGenerator.VARIABLE_CURSOR;

  static const String _EOF = ParserClassGenerator.CONSTANT_EOF;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = ParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME() {
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS) {
    var result = new String.fromCharCode($_CH);
    if (++$_CURSOR < $_INPUT_LEN) {
      $_CH = $_RUNES[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
    return result;
  }
  if ($_CURSOR > $_TESTING) {
    $_FAILURE();
  }  
  return null;  
}
''';

  MethodMatchAnyGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
