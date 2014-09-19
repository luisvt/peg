part of string_matching.class_generator;

class ClassGenerator extends TemplateGenerator {
  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
class {{CLASSNAME}} {
  {{#VARIABLES}}

  {{#CONSTRUCTORS}}
  {{#MUTATORS}} 
  {{#METHODS}}  
  {{#CODE}}
}
''';

  List<List<String>> code;

  List<List<String>> constructors;

  List<List<String>> methods;

  String name;

  List<List<String>> mutators;

  List<List<String>> variables;

  ClassGenerator({this.code, this.constructors, this.methods, this.mutators, this.name, this.variables}) {
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

    if (code != null) {
      block.assign("#CODE", code);
    }

    if (constructors != null) {
      block.assign("#CONSTRUCTORS", constructors);
    }

    if (mutators != null) {
      block.assign("#MUTATORS", mutators);
    }

    if (methods != null) {
      block.assign("#METHODS", methods);
    }

    return block.process();
  }
}
