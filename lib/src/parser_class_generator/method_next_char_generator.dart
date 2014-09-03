part of peg.grammar_generator;

// TODO: remove "MethodNextCharGenerator"
class MethodNextCharGenerator extends TemplateGenerator {
  static const String NAME = "_nextChar";

  static const String _CH = ParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = ParserClassGenerator.VARIABLE_CURSOR;

  static const String _EOF = ParserClassGenerator.CONSTANT_EOF;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME([int count = 1]) {  
  $_SUCCESS = true;
  $_CURSOR += count; 
  if ($_CURSOR < $_INPUT_LEN) {
    $_CH = $_RUNES[$_CURSOR];
  } else {
    $_CH = $_EOF;
  }    
}
''';

  MethodNextCharGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
