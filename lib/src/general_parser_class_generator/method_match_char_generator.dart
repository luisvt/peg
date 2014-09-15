part of peg.grammar_generator;

class MethodMatchCharGenerator extends TemplateGenerator {
  static const String NAME = "_matchChar";

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
String $NAME(int ch, String string) {
  $_SUCCESS = $_CH == ch;
  if ($_SUCCESS) {
    var result = string;  
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

  MethodMatchCharGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
