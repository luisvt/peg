part of peg.grammar_generator;

class MethodMatchAnyGenerator extends TemplateGenerator {
  static const String NAME = "_matchAny";

  static const String _ASCII = GeneralParserClassGenerator.VARIABLE_ASCII;

  static const String _CH = GeneralParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _EOF = GeneralParserClassGenerator.CONSTANT_EOF;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = GeneralParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GeneralParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME() {
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS) {
    String result;
    if ($_CH < 128) {
      result = $_ASCII[$_CH];  
    } else {
      result = new String.fromCharCode($_CH);
    }    
    if (++$_CURSOR < $_INPUT_LEN) {
      $_CH = $_RUNES[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
    return result;
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
