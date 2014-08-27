part of peg.grammar_generator;

class ClassGenerator extends TemplateGenerator {
  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
class {{CLASSNAME}} {
  {{#VARIABLES}}
  {{#CONSTRUCTORS}}
  {{#PROPERTIES}} 
  {{#METHODS}}
}
''';

  dynamic constructors;

  dynamic methods;

  String name;

  dynamic properties;

  dynamic variables;



  ClassGenerator({this.constructors, this.methods, this.name, this.properties,
      this.variables}) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("CLASSNAME", name);
    if (variables != null) {
      block.assign("#VARIABLES", variables);
    }

    if (constructors != null) {
      block.assign("#CONSTRUCTORS", constructors);
    }

    if (properties != null) {
      block.assign("#PROPERTIES", properties);
    }

    if (methods != null) {
      block.assign("#METHODS", methods);
    }

    return block.process();
  }
}
