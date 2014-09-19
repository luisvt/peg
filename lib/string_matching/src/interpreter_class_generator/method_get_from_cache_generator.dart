part of string_matching.interpreter_class_generator;

class MethodGetFromCacheGenerator extends MethodGenerator {
  static const String NAME = "_getFromCache";

  static const String _CACHE = GlobalNaming.CACHE;

  static const String _CACHE_RULE = GlobalNaming.CACHE_RULE;

  static const String _CACHE_STATE = GlobalNaming.CACHE_STATE;

  static const String _CH = GlobalNaming.CH;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _EOF = GlobalNaming.EOF;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

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
        $_CH = $_RUNES[$_CURSOR];
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
    $_CH = $_RUNES[$_CURSOR];
  } else {
    $_CH = $_EOF;
  }   
  return data;  
}
''';

  MethodGetFromCacheGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
