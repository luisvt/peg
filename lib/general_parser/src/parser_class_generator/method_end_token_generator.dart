part of peg.general_parser.parser_class_generator;

class MethodEndTokenGenerator extends DeclarationGenerator {
  static const String NAME = "_endToken";

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_LEVEL = ParserClassGenerator.TOKEN_LEVEL;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME() {
  if (--$_TOKEN_LEVEL == 0) {
    $_TOKEN = null;
    $_TOKEN_START = null;
  }    
}
''';

  MethodEndTokenGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
