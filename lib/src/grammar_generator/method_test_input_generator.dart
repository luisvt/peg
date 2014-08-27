part of peg.grammar_generator;

class MethodTestInputGenerator extends TemplateGenerator {
  static const String NAME = "_testInput";

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _TEXT = GrammarGenerator.VARIABLE_TEXT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
bool $NAME(int flag) {
  if ($_INPUT_POS >= $_INPUT_LEN) {
    return false;
  }
  var c = $_TEXT.codeUnitAt($_INPUT_POS);
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
