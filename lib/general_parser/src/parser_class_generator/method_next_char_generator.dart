part of peg.general_parser.parser_class_generator;

class MethodNextCharGenerator extends DeclarationGenerator {
  static const String NAME = "_nextChar";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME() {
  if (++$_CURSOR < $_INPUT_LEN) {
    $_CH = $_INPUT[$_CURSOR];
  } else {
    $_CH = $_EOF;
  }  
}
''';

  MethodNextCharGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
