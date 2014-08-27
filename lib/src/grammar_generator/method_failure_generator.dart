part of peg.grammar_generator;

class MethodFailureGenerator extends TemplateGenerator {
  static const String NAME = "_failure";

  static const String _EXPECTED = GrammarGenerator.VARIABLE_EXPECTED;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _FAILURE_POS = GrammarGenerator.VARIABLE_FAILURE_POS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template =
      '''
void $NAME([List<String> expected]) {  
  if ($_FAILURE_POS > $_INPUT_POS) {
    return;
  }
  if ($_INPUT_POS > $_FAILURE_POS) {    
    $_EXPECTED = [];
   $_FAILURE_POS = $_INPUT_POS;
  }
  if (expected != null) {
    $_EXPECTED.addAll(expected);
  }  
}
''';

  MethodFailureGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
