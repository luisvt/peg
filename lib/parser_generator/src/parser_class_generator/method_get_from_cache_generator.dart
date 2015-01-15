part of peg.parser_generators.parser_class_generator;

class MethodGetFromCacheGenerator extends DeclarationGenerator {
  static const String NAME = "_getFromCache";

  static const String _CACHE = ParserClassGenerator.CACHE;

  static const String _CACHE_RULE = ParserClassGenerator.CACHE_RULE;

  static const String _CACHE_STATE = ParserClassGenerator.CACHE_STATE;

  static const String _CACHEABLE = ParserClassGenerator.CACHEABLE;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TRACK_POS = ParserClassGenerator.TRACK_POS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic $NAME(int id) {  
  if (!$_CACHEABLE[id]) {
    if ($_TRACK_POS[id] < $_CURSOR) {
      $_TRACK_POS[id] = $_CURSOR;
      return null;
    } else {
      $_CACHEABLE[id] = true;            
    }
  }  
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
        $_CH = $_INPUT[$_CURSOR];
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
    $_CH = $_INPUT[$_CURSOR];
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
