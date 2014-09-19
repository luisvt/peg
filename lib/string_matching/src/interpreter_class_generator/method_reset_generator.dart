part of string_matching.interpreter_class_generator;

class MethodResetGenerator extends MethodGenerator {
  static const String NAME = "reset";

  static const String _CACHE = GlobalNaming.CACHE;

  static const String _CACHE_POS = GlobalNaming.CACHE_POS;

  static const String _CACHE_RULE = GlobalNaming.CACHE_RULE;

  static const String _CACHE_STATE = GlobalNaming.CACHE_STATE;

  static const String _CH = GlobalNaming.CH;

  static const String _COLUMN = GlobalNaming.COLUMN;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _EOF = GlobalNaming.EOF;

  static const String _EXPECTED = GlobalNaming.EXPECTED;

  static const String _FAILURE_POS = GlobalNaming.FAILURE_POS;

  static const String _FLAG = GlobalNaming.FLAG;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _LINE = GlobalNaming.LINE;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TESTING = GlobalNaming.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static const String _TEMPLATE_CHECK_STACK = "TEMPLATE_CHECK_STACK";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null) {
    throw new ArgumentError('pos: \$pos');
  }
  if (pos < 0 || pos > $_INPUT_LEN) {
    throw new RangeError('pos');
  } 
  $_RESULT = null;
  $_SUCCESS = true;
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

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
