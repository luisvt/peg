part of peg.parser_generators.parser_class_generator;

class MethodListGenerator extends DeclarationGenerator {
  static const String NAME = "_list";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List $NAME(Object first, List next) {
  var length = next.length;
  var list = new List(length + 1);
  list[0] = first;
  for (var i = 0; i < length; i++) {
    list[i + 1] = next[i][1];
  }
  return list;
}
''';

  MethodListGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
