part of peg.interpreter_class_generator;

class MethodParseEntryGenerator extends TemplateGenerator {
  static const String _PARSE = MethodParseGenerator.NAME;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
dynamic parse_{{NAME}}() {
  // TODO: pos = 0
  return $_PARSE({{CODE}}, {{DATA}}, 0);
}
''';

  String _name;

  MethodParseEntryGenerator(String name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    _name = name;
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var camelCase = camelize(_name, true);
    block.assign("CODE", "_${camelCase}Code");
    block.assign("DATA", "_${camelCase}Data");
    block.assign("NAME", _name);
    return block.process();
  }
}
