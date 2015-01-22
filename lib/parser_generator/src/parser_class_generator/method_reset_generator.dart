part of peg.parser_generators.parser_class_generator;

class MethodResetGenerator extends DeclarationGenerator {
  static const String NAME = "reset";

  static const String _CACHE = ParserClassGenerator.CACHE;

  static const String _CACHE_POS = ParserClassGenerator.CACHE_POS;

  static const String _CACHEABLE = ParserClassGenerator.CACHEABLE;

  static const String _CACHING = ParserClassGenerator.CACHING;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _ERRORS = ParserClassGenerator.ERRORS;

  static const String _EXPECTED = ParserClassGenerator.EXPECTED;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _FAILURE_POS = ParserClassGenerator.FAILURE_POS;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _START_POS = ParserClassGenerator.START_POS;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_LEVEL = ParserClassGenerator.TOKEN_LEVEL;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int pos) {
  if (pos == null) {
    throw new ArgumentError('pos: \$pos');
  }
  if (pos < 0 || pos > $_INPUT_LEN) {
    throw new RangeError('pos');
  }      
  $_CURSOR = pos;
  $_CACHE = new List<Map<int, List>>({{RULE_COUNT}});
  $_CACHE_POS = new List<int>.filled({{RULE_COUNT}}, -1);  
  $_CACHEABLE = new List<bool>.filled({{RULE_COUNT}}, false);
  $_CACHING = true;
  $_CH = $_EOF;
  $_ERRORS = <{{ERROR_CLASS}}>[];   
  $_EXPECTED = <String>[];
  $_FAILURE_POS = -1;
  $_START_POS = pos;        
  $_TESTING = -1;
  $_TOKEN = null;
  $_TOKEN_LEVEL = 0;
  $_TOKEN_START = null;  
  if ($_CURSOR < $_INPUT_LEN) {
    $_CH = $_INPUT[$_CURSOR];
  }
  $_SUCCESS = true;    
}
''';

  final ParserClassGenerator parserClassGenerator;

  final int ruleCount;

  MethodResetGenerator(this.parserClassGenerator, this.ruleCount) {
    if (parserClassGenerator == null) {
      throw new ArgumentError("parserClassGenerator: $parserClassGenerator");
    }

    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var parserName = parserClassGenerator.name;
    var errorClass = ParserErrorClassGenerator.getName(parserName);
    block.assign("RULE_COUNT", ruleCount + 1);
    block.assign("ERROR_CLASS", errorClass);
    return block.process();
  }
}
