part of string_matching.interpreter_class_generator;

class MethodParseGenerator extends MethodGenerator {
  static const String NAME = "_parse";

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic $NAME(int cp) {
  $_DECODE(cp);
  return $_RESULT;
}
''';

  MethodParseGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
