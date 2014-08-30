part of peg.grammar_generator;

class MethodTestInputGenerator extends TemplateGenerator {
  static const String NAME = "_testInput";

  static const String _CURSOR = GrammarGenerator.VARIABLE_CURSOR;

  static const String _INPUT = GrammarGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
bool $NAME(int flag) {
  if ($_CURSOR >= $_INPUT_LEN) {
    return false;
  }
  var c = $_INPUT.codeUnitAt($_CURSOR);
  if (c < 0 || c > 127) {
    return false;
  }    
  int slot = (c & 0xff) >> 6;  
  int mask = 1 << c - ((slot << 6) & 0x3fffffff);  
  if ((flag & mask) != 0) {    
    return true;
  }
  return false;           
}
''';

  MethodTestInputGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
