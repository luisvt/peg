part of string_matching.interpreter_class_generator;

class MethodAddToCacheGenerator extends MethodGenerator {
  static const String NAME = "_addToCache";

  static const String _CACHE = GlobalNaming.CACHE;

  static const String _CACHE_POS = GlobalNaming.CACHE_POS;

  static const String _CACHE_RULE = GlobalNaming.CACHE_RULE;

  static const String _CACHE_STATE = GlobalNaming.CACHE_STATE;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(dynamic result, int start, int id) {  
  var cached = $_CACHE[start];
  if (cached == null) {
    $_CACHE_RULE[start] = id;
    $_CACHE[start] = [result, $_CURSOR, $_SUCCESS];
  } else {    
    var slot = start >> 5;
    var r1 = (slot << 5) & 0x3fffffff;    
    var mask = 1 << (start - r1);    
    if (($_CACHE_STATE[slot] & mask) == 0) {
      $_CACHE_STATE[slot] |= mask;   
      cached = [new List.filled({{SIZE}}, 0), new Map<int, List>()];
      $_CACHE[start] = cached;                                      
    }
    slot = id >> 5;
    r1 = (slot << 5) & 0x3fffffff;    
    mask = 1 << (id - r1);    
    cached[0][slot] |= mask;
    cached[1][id] = [result, $_CURSOR, $_SUCCESS];      
  }
  if ($_CACHE_POS < start) {
    $_CACHE_POS = start;
  }    
}
''';

  int _size;

  MethodAddToCacheGenerator(int size) {
    if (size == null || size < 0) {
      throw new ArgumentError("size: $size");
    }

    _size = size;
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("SIZE", _size);
    return block.process();
  }
}
