part of peg.grammar_generator;

class MethodMatchRangesGenerator extends TemplateGenerator {
  static const String NAME = "_matchRanges";

  static const String _CH = ParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = ParserClassGenerator.VARIABLE_CURSOR;

  static const String _EOF = ParserClassGenerator.CONSTANT_EOF;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT = ParserClassGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = ParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(List<int> ranges) {
  var length = ranges.length;
  for (var i = 0; i < length; i += 2) {
    if ($_CH <= ranges[i + 1]) {
      if ($_CH >= ranges[i]) {
        var result = $_INPUT[$_CURSOR++];
        if ($_CURSOR < $_INPUT_LEN) {
          $_CH = $_RUNES[$_CURSOR];
        } else {
           $_CH = $_EOF;
        }
        $_SUCCESS = true;    
        return result;
      }      
    } else break;  
  }
  if ($_CURSOR > $_TESTING) {
    $_FAILURE();
  }
  $_SUCCESS = false;  
  return null;  
}
''';

  MethodMatchRangesGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
