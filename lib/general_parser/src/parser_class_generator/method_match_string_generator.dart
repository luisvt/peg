part of peg.general_parser.parser_class_generator;

class MethodMatchStringGenerator extends DeclarationGenerator {
  static const String NAME = "_matchString";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(List<int> codePoints, String string) {
  var length = codePoints.length;  
  $_SUCCESS = $_CURSOR + length <= $_INPUT_LEN;
  if ($_SUCCESS) {
    for (var i = 0; i < length; i++) {
      if (codePoints[i] != $_INPUT[$_CURSOR + i]) {
        $_SUCCESS = false;
        break;
      }
    }
  } else {
    $_SUCCESS = false;
  }  
  if ($_SUCCESS) {
    $_CURSOR += length;      
    if ($_CURSOR < $_INPUT_LEN) {
      $_CH = $_INPUT[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
    return string;      
  }  
  return null; 
}
''';

  MethodMatchStringGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
