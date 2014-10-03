part of peg.general_parser.parser_class_generator;

class MethodMatchRangesGenerator extends DeclarationGenerator {
  static const String NAME = "_matchRanges";

  static const String _ASCII = ParserClassGenerator.ASCII;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(List<int> ranges) {
  var length = ranges.length;
  for (var i = 0; i < length; i += 2) {    
    if ($_CH >= ranges[i]) {
      if ($_CH <= ranges[i + 1]) {
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
        $_SUCCESS = true;    
        return result;
      }      
    } else break;  
  }
  $_SUCCESS = false;  
  return null;  
}
''';

  MethodMatchRangesGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
