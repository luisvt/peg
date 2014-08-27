part of peg.grammar_generator;

// TODO: remove "MethodNextCharGenerator"
class MethodNextCharGenerator extends TemplateGenerator {
  static const String NAME = "_nextChar";

  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _EOF = GrammarGenerator.CONSTANT_EOF;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TEXT = GrammarGenerator.VARIABLE_TEXT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template =
      '''
void $NAME([int count = 1]) {  
  $_SUCCESS = true;
  $_INPUT_POS += count; 
  if ($_INPUT_POS < $_INPUT_LEN) {
    $_CH = $_TEXT.codeUnitAt($_INPUT_POS);
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
