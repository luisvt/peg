part of peg.grammar_generator;

class MethodResetGenerator extends TemplateGenerator {
  static const String NAME = "reset";

  static const String _CACHE = GeneralParserClassGenerator.VARIABLE_CACHE;

  static const String _CACHE_POS = GeneralParserClassGenerator.VARIABLE_CACHE_POS;

  static const String _CACHE_RULE = GeneralParserClassGenerator.VARIABLE_CACHE_RULE;

  static const String _CACHE_STATE = GeneralParserClassGenerator.VARIABLE_CACHE_STATE;

  static const String _CH = GeneralParserClassGenerator.VARIABLE_CH;

  static const String _COLUMN = GeneralParserClassGenerator.VARIABLE_COLUMN;

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _EXPECTED = GeneralParserClassGenerator.VARIABLE_EXPECTED;

  static const String _EOF = GeneralParserClassGenerator.CONSTANT_EOF;

  static const String _FAILURE_POS = GeneralParserClassGenerator.VARIABLE_FAILURE_POS;

  static const String _FLAG = GeneralParserClassGenerator.VARIABLE_FLAG;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _LINE = GeneralParserClassGenerator.VARIABLE_LINE;

  static const String _RUNES = GeneralParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GeneralParserClassGenerator.VARIABLE_TESTING;

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
