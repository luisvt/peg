part of peg.parser_generators.parser_class_generator;

class MethodBeginTokenGenerator extends DeclarationGenerator {
  static const String NAME = "_beginToken";

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_LEVEL = ParserClassGenerator.TOKEN_LEVEL;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int tokenId) {
  if ($_TOKEN_LEVEL++ == 0) {
    $_TOKEN = tokenId;
    $_TOKEN_START = _cursor;
  }  
}
''';

  MethodBeginTokenGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
