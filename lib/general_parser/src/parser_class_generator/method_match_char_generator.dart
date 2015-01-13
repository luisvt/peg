part of peg.general_parser.parser_class_generator;

class MethodMatchCharGenerator extends DeclarationGenerator {
  static const String NAME = "_matchChar";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(int ch, String string) {
  $_SUCCESS = $_CH == ch;
  if ($_SUCCESS) {
    var result = string;  
    if (++$_CURSOR < $_INPUT_LEN) {
      $_CH = $_INPUT[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
    return result;
  }  
  return null;  
}
''';

  MethodMatchCharGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
