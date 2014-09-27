part of peg.general_parser.parser_class_generator;

class MethodMatchRangeGenerator extends DeclarationGenerator {
  static const String NAME = "_matchRange";

  static const String _ASCII = GeneralParserClassGenerator.ASCII;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(int start, int end) {
  $_SUCCESS = $_CH >= start && $_CH <= end;
  if ($_SUCCESS) {
    String result;
    if ($_CH < 128) {
      result = $_ASCII[$_CH];  
    } else {
      result = new String.fromCharCode($_CH);
    }        
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

  MethodMatchRangeGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
