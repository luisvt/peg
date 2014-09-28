part of peg.general_parser.parser_class_generator;

class MethodGetStateGenerator extends DeclarationGenerator {
  static const String NAME = "_getState";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_LEVEL = ParserClassGenerator.TOKEN_LEVEL;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
int $NAME(List<List<int>> transitions) {
  var count = transitions.length;
  var state = 0;
  for ( ; state < count; state++) {
    var ranges = transitions[state];
    var length = ranges.length;
    for (var i = 0; i < length; i += 2) {
      if ($_CH >= ranges[i]) {
        if ($_CH <= ranges[i + 1]) {
          return state;
        }
      } else {
        break;
      }      
    } 
  }
  if (_ch != -1) {
    return state;
  }
  return state + 1;  
}
''';

  MethodGetStateGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
