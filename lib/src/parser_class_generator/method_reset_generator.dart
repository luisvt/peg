part of peg.grammar_generator;

class MethodResetGenerator extends TemplateGenerator {
  static const String NAME = "reset";

  static const String _CACHE = ParserClassGenerator.VARIABLE_CACHE;

  static const String _CACHE_POS = ParserClassGenerator.VARIABLE_CACHE_POS;

  static const String _CACHE_RULE = ParserClassGenerator.VARIABLE_CACHE_RULE;

  static const String _CACHE_STATE = ParserClassGenerator.VARIABLE_CACHE_STATE;

  static const String _CH = ParserClassGenerator.VARIABLE_CH;

  static const String _COLUMN = ParserClassGenerator.VARIABLE_COLUMN;

  static const String _CURSOR = ParserClassGenerator.VARIABLE_CURSOR;

  static const String _EXPECTED = ParserClassGenerator.VARIABLE_EXPECTED;

  static const String _EOF = ParserClassGenerator.CONSTANT_EOF;

  static const String _FAILURE_POS = ParserClassGenerator.VARIABLE_FAILURE_POS;

  static const String _FLAG = ParserClassGenerator.VARIABLE_FLAG;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _LINE = ParserClassGenerator.VARIABLE_LINE;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = ParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null) {
    throw new ArgumentError('pos: \$pos');
  }
  if (pos < 0 || pos > $_INPUT_LEN) {
    throw new RangeError('pos');
  }      
  $_CURSOR = pos;
  $_CACHE = new List($_INPUT_LEN + 1);
  $_CACHE_POS = -1;
  $_CACHE_RULE = new List($_INPUT_LEN + 1);
  $_CACHE_STATE = new List.filled((($_INPUT_LEN + 1) >> 5) + 1, 0);
  $_CH = $_EOF;  
  $_COLUMN = -1; 
  $_EXPECTED = [];
  $_FAILURE_POS = -1;
  $_FLAG = 0;  
  $_LINE = -1;
  $_SUCCESS = true;    
  $_TESTING = -1;
  if ($_CURSOR < $_INPUT_LEN) {
    $_CH = $_RUNES[$_CURSOR];
  }    
}
''';

  MethodResetGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
