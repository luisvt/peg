part of peg.general_parser.parser_class_generator;

class MethodMatchMappingGenerator extends DeclarationGenerator {
  static const String NAME = "_matchMapping";

  static const String _ASCII = GeneralParserClassGenerator.ASCII;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(int start, int end, List<bool> mapping) {
  $_SUCCESS = $_CH >= start && $_CH <= end;
  if ($_SUCCESS) {    
    if(mapping[$_CH - start]) {
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
    $_SUCCESS = false;
  }  
  return null;  
}
''';

  MethodMatchMappingGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
