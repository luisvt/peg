part of peg.helper_methods_generators;

class MethodRuneAtGenerator extends TemplateGenerator {
  static const String NAME = "_runeAt";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
int $NAME(String string, int index) {
  // TODO: Optimize $NAME()
  return string.runes.toList(growable: false)[index];
}
''';

MethodRuneAtGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
