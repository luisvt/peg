part of peg.grammar_generator;

class MethodTestCharGenerator extends TemplateGenerator {
  static const String NAME = "_testChar";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template =
      '''
bool $NAME(int c, int flag) {
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

  MethodTestCharGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
