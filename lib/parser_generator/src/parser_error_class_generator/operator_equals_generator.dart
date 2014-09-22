part of peg.parser_generators.parser_error_class_generator;

class OperatorEqualsGenerator extends DeclarationGenerator {
  static const String LENGTH = ParserErrorClassGenerator.START;

  static const String MESSAGE = ParserErrorClassGenerator.MESSAGE;

  static const String POSITION = ParserErrorClassGenerator.POSITION;

  static const String TYPE = ParserErrorClassGenerator.TYPE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
bool operator ==(other) {
  if (identical(this, other)) return true;
  if (other is {{CLASSNAME}}) {
    return $TYPE == other.$TYPE && $POSITION == other.$POSITION &&
    $LENGTH == other.$LENGTH && $MESSAGE == other.$MESSAGE;  
  }
  return false;
}
''';

  final String name;

  OperatorEqualsGenerator(this.name) {
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
