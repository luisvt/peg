part of peg.parser_generators.parser_class_generator;

class MethodAddToCacheGenerator extends DeclarationGenerator {
  static const String NAME = "_addToCache";

  static const String _CACHE = ParserClassGenerator.CACHE;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(dynamic result, int start, int id) {   
  var map = $_CACHE[id];
  if (map == null) {
    map = <int, List>{};
    $_CACHE[id] = map;
  }
  map[start] = [result, $_CURSOR, $_SUCCESS];      
}
''';

  MethodAddToCacheGenerator(Grammar grammar) {
    if (grammar == null) {
      throw new ArgumentError("grammar: $grammar");
    }

    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
