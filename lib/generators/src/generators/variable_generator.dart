part of peg.generators.generators;

class VariableGenerator extends DeclarationGenerator {
  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
{{#COMMENT}}
{{#DECLARATION}}
''';

  final String comment;

  final String name;

  final String type;

  final String value;

  VariableGenerator(this.name, this.type, {this.comment, this.value}) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    if (comment != null) {
      block.assign("#COMMENT", comment);
    }

    var sb = new StringBuffer();
    if (type != null) {
      sb.write(type);
      sb.write(" ");
    }

    sb.write(name);
    if (value != null) {
      sb.write(" = ");
      sb.write(value);
    }

    sb.write(";");
    block.assign("#DECLARATION", sb.toString());
    return block.process();
  }
}
