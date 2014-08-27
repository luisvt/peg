part of peg.grammar_generator;

class MethodAddToCacheGenerator extends TemplateGenerator {
  static const String NAME = "_addToCache";

  static const String _CACHE = GrammarGenerator.VARIABLE_CACHE;

  static const String _CACHE_POS = GrammarGenerator.VARIABLE_CACHE_POS;

  static const String _CACHE_RULE = GrammarGenerator.VARIABLE_CACHE_RULE;

  static const String _CACHE_STATE = GrammarGenerator.VARIABLE_CACHE_STATE;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template =
      '''
void $NAME(dynamic result, int start, int id) {  
  var cached = $_CACHE[start];
  if (cached == null) {
    $_CACHE_RULE[start] = id;
    $_CACHE[start] = [result, $_INPUT_POS, $_SUCCESS];
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
    cached[1][id] = [result, $_INPUT_POS, $_SUCCESS];      
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

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("SIZE", _size);
    return block.process();
  }
}
