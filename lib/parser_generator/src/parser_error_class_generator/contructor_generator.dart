part of peg.parser_generators.parser_error_class_generator;

class ClassContructorGenerator extends DeclarationGenerator {
  static const String MESSAGE = ParserErrorClassGenerator.MESSAGE;

  static const String POSITION = ParserErrorClassGenerator.POSITION;

  static const String START = ParserErrorClassGenerator.START;

  static const String TYPE = ParserErrorClassGenerator.TYPE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
{{CLASSNAME}}(this.$TYPE, this.$POSITION, this.$START, this.$MESSAGE);
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
