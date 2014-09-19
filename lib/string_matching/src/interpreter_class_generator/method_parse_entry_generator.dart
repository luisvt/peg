part of string_matching.interpreter_class_generator;

class MethodParseEntryGenerator extends MethodGenerator {
  static const String _PARSE = MethodParseGenerator.NAME;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic parse_{{NAME}}() => $_PARSE({{CP}});
''';

  final Instruction instruction;

  final String name;

  MethodParseEntryGenerator(this.instruction, this.name) {
    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("CP", instruction.address);
    block.assign("NAME", name);
    return block.process();
  }
}
