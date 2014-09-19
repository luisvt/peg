part of string_matching.interpreter_class_generator;

class AccessorLineGenerator extends MethodGenerator {
  static const String NAME = "line";

  static const String _CALCULATE_POS = MethodCalculatePosGenerator.NAME;

  static const String _FAILURE_POS = GlobalNaming.FAILURE_POS;

  static const String _LINE = GlobalNaming.LINE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
int get $NAME {
  if ($_LINE == -1) {
    $_CALCULATE_POS($_FAILURE_POS);
  }
  return $_LINE;      
}
''';

  AccessorLineGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    return getTemplateBlock(_TEMPLATE).process();
  }
}
