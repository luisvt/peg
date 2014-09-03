part of peg.interpreter_class_generator;

class ClassContructorGenerator extends TemplateGenerator {
  static const String _INPUT = InterpreterClassGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = InterpreterClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RUNES = InterpreterClassGenerator.VARIABLE_RUNES;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
{{CLASSNAME}}(String text) {
  if (text == null) {
    throw new ArgumentError('text: \$text');
  }
  $_INPUT = text;  
  $_INPUT_LEN = $_INPUT.length;
  $_RUNES = text.runes.toList(growable: false);
  if ($_INPUT_LEN >= 0x3fffffe8 / 32) {
    throw new StateError('File size to big: \$$_INPUT_LEN');
  }      
}
''';

  String name;

  ClassContructorGenerator(this.name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign('CLASSNAME', name);
    return block.process();
  }
}
