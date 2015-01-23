part of peg.general_parser.parser_class_generator;

class MethodGetStateGenerator extends DeclarationGenerator {
  static const String NAME = "_getState";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
int $NAME(List<List<int>> transitions) {
  var count = transitions.length;
  var state = 0;
  for ( ; state < count; state++) {
    var found = false;
    var ranges = transitions[state];    
    while (true) {
      var right = ranges.length ~/ 2;
      if (right == 0) {
        break;
      }
      var left = 0;
      if (right == 1) {
        if ($_CH <= ranges[1] && $_CH >= ranges[0]) {
          found = true;          
        }
        break;
      }
      int middle;
      while (left < right) {
        middle = (left + right) >> 1;
        var index = middle << 1;
        if (ranges[index + 1] < $_CH) {
          left = middle + 1;
        } else {
          if ($_CH >= ranges[index]) {
            found = true;
            break;
          }
          right = middle;
        }
      }
      break;
    }
    if (found) {
      return state; 
    }   
  }
  if ($_CH != -1) {
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
