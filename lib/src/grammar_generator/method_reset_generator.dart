part of peg.grammar_generator;

class MethodResetGenerator extends TemplateGenerator {
  static const String NAME = "reset";

  static const String _CACHE = GrammarGenerator.VARIABLE_CACHE;

  static const String _CACHE_POS = GrammarGenerator.VARIABLE_CACHE_POS;

  static const String _CACHE_RULE = GrammarGenerator.VARIABLE_CACHE_RULE;

  static const String _CACHE_STATE = GrammarGenerator.VARIABLE_CACHE_STATE;

  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _COLUMN = GrammarGenerator.VARIABLE_COLUMN;

  static const String _CURSOR = GrammarGenerator.VARIABLE_CURSOR;

  static const String _EXPECTED = GrammarGenerator.VARIABLE_EXPECTED;

  static const String _EOF = GrammarGenerator.CONSTANT_EOF;

  static const String _FAILURE_POS = GrammarGenerator.VARIABLE_FAILURE_POS;

  static const String _FLAG = GrammarGenerator.VARIABLE_FLAG;

  static const String _INPUT = GrammarGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _LINE = GrammarGenerator.VARIABLE_LINE;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GrammarGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null) {
    throw new ArgumentError('pos: \$pos');
  }
  if (pos < 0 || pos > $_INPUT_LEN) {
    throw new RangeError('pos');
  }
  $_SUCCESS = true;    
  $_CACHE = new List($_INPUT_LEN + 1);
  $_CACHE_POS = -1;
  $_CACHE_RULE = new List($_INPUT_LEN + 1);
  $_CACHE_STATE = new List.filled((($_INPUT_LEN + 1) >> 5) + 1, 0);
  $_CH = $_EOF;  
  $_COLUMN = -1; 
  $_EXPECTED = [];
  $_FAILURE_POS = -1;
  $_FLAG = 0;  
  $_CURSOR = pos;
  $_LINE = -1;    
  $_TESTING = -1;
  if (pos < $_INPUT_LEN) {
    $_CH = $_INPUT.codeUnitAt(pos);
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
