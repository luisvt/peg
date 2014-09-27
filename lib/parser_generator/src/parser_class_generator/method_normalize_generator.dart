part of peg.parser_generators.parser_class_generator;

class MethodNormalizeGenerator extends DeclarationGenerator {
  static const String NAME = "_normalize";

  static const String _COMPACT = MethodCompactGenerator.NAME;

  static const String _FLATTEN = MethodFlattenGenerator.NAME;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List $NAME(dynamic value) {
  if (value == null) {
    return [];
  }
  return $_FLATTEN($_COMPACT(value));
}
''';

  MethodNormalizeGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
