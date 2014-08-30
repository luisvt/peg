part of peg.grammar_generator;

class MethodGetFromCacheGenerator extends TemplateGenerator {
  static const String NAME = "_getFromCache";

  static const String _CACHE = GrammarGenerator.VARIABLE_CACHE;

  static const String _CACHE_RULE = GrammarGenerator.VARIABLE_CACHE_RULE;

  static const String _CACHE_STATE = GrammarGenerator.VARIABLE_CACHE_STATE;

  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _CURSOR = GrammarGenerator.VARIABLE_CURSOR;

  static const String _EOF = GrammarGenerator.CONSTANT_EOF;

  static const String _INPUT = GrammarGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic $NAME(int id) {  
  var result = $_CACHE[$_CURSOR];
  if (result == null) {
    return null;
  }    
  var slot = $_CURSOR >> 5;
  var r1 = (slot << 5) & 0x3fffffff;  
  var mask = 1 << ($_CURSOR - r1);
  if (($_CACHE_STATE[slot] & mask) == 0) {
    if ($_CACHE_RULE[$_CURSOR] == id) {      
      $_CURSOR = result[1];
      $_SUCCESS = result[2];      
      if ($_CURSOR < $_INPUT_LEN) {
        $_CH = $_INPUT.codeUnitAt($_CURSOR);
      } else {
        $_CH = $_EOF;
      }      
      return result;
    } else {
      return null;
    }    
  }
  slot = id >> 5;
  r1 = (slot << 5) & 0x3fffffff;  
  mask = 1 << (id - r1);
  if ((result[0][slot] & mask) == 0) {
    return null;
  }
  var data = result[1][id];  
  $_CURSOR = data[1];
  $_SUCCESS = data[2];
  if ($_CURSOR < $_INPUT_LEN) {
    $_CH = $_INPUT.codeUnitAt($_CURSOR);
  } else {
    $_CH = $_EOF;
  }   
  return data;  
}
''';

  MethodGetFromCacheGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
