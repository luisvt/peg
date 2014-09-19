part of string_matching.interpreter_class_generator;

class AcessorUnexpectedGenerator extends MethodGenerator {
  static const String NAME = "unexpected";

  static const String _FAILURE_POS = GlobalNaming.FAILURE_POS;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String get $NAME {
  if ($_FAILURE_POS < 0 || $_FAILURE_POS >= $_INPUT_LEN) {
    return '';    
  }
  return new String.fromCharCode($_RUNES[$_FAILURE_POS]);  
}
''';

  AcessorUnexpectedGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
