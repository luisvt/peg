part of peg.parser_generators.parser_class_generator;

class MethodTextGenerator extends DeclarationGenerator {
  static const String NAME = "_text";

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _START_POS = ParserClassGenerator.START_POS;

  static const String _TEXT = ParserClassGenerator.TEXT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME() {
  return new String.fromCharCodes($_INPUT.sublist($_START_POS, $_CURSOR));
}
''';

  MethodTextGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
