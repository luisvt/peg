part of peg.grammar_generator;

class MethodExpectedGenerator extends TemplateGenerator {
  static const String NAME = "expected";

  static const String _EXPECTED = ParserClassGenerator.VARIABLE_EXPECTED;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List<String> get $NAME {
  var set = new Set<String>();  
  set.addAll($_EXPECTED);
  if (set.contains(null)) {
    set.clear();
  }  
  var result = set.toList();
  result.sort(); 
  return result;        
}
''';

  MethodExpectedGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
