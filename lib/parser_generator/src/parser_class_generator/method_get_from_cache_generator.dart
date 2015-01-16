part of peg.parser_generators.parser_class_generator;

class MethodGetFromCacheGenerator extends DeclarationGenerator {
  static const String NAME = "_getFromCache";

  static const String _CACHE = ParserClassGenerator.CACHE;

  static const String _CACHEABLE = ParserClassGenerator.CACHEABLE;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic $NAME(int id) {  
  if (!$_CACHEABLE[id]) {  
    $_CACHEABLE[id] = true;  
    return null;
  }
  var map = $_CACHE[id];
  if (map == null) {
    return null;
  }
  var data = map[$_CURSOR];
  $_CURSOR = data[1];
  $_SUCCESS = data[2];
  if ($_CURSOR < $_INPUT_LEN) {
    $_CH = $_INPUT[$_CURSOR];
  } else {
    $_CH = -1;
  }
  return data;  
}
''';

  MethodGetFromCacheGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
