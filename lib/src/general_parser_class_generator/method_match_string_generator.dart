part of peg.grammar_generator;

class MethodMatchStringGenerator extends TemplateGenerator {
  static const String NAME = "_matchString";

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
String $NAME(List<int> runes, String string) {
  var length = runes.length;  
  $_SUCCESS = true;  
  if ($_CURSOR + length < $_INPUT_LEN) {
    for (var i = 0; i < length; i++) {
      if (runes[i] != $_RUNES[$_CURSOR + i]) {
        $_SUCCESS = false;
        break;
      }
    }
  } else {
    $_SUCCESS = false;
  }  
  if ($_SUCCESS) {
    $_CURSOR += length;      
    if ($_CURSOR < $_INPUT_LEN) {
      $_CH = $_RUNES[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
    return string;      
  }  
  return null; 
}
''';

  MethodMatchStringGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
