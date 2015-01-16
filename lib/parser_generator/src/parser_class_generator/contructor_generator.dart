part of peg.parser_generators.parser_class_generator;

class ClassContructorGenerator extends DeclarationGenerator {
  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESET = MethodResetGenerator.NAME;

  static const String _TO_CODE_POINTS = MethodToCodePointsGenerator.NAME;

  static const String _TEXT = ParserClassGenerator.TEXT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
{{CLASSNAME}}(this.$_TEXT) {
  if ($_TEXT == null) {
    throw new ArgumentError('$_TEXT: \$text');
  }    
  $_INPUT = $_TO_CODE_POINTS($_TEXT);
  $_INPUT_LEN = $_INPUT.length;    
  $_RESET(0);    
}
''';

  final String name;

  ClassContructorGenerator(this.name) {
    if (name == null) {
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
