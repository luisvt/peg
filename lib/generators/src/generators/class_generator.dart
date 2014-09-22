part of peg.generators.generators;

class ClassGenerator extends DeclarationGenerator {
  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
class {{CLASSNAME}} {
  {{#CONSTANTS}}    
  {{#STATIC_VARIABLES}}
  {{#STATIC_PROPERTIES}}
  {{#STATIC_METHODS}}  
  {{#VARIABLES}}
  {{#CONSTRUCTORS}}
  {{#PROPERTIES}} 
  {{#OPERATORS}}
  {{#METHODS}}
  {{#CODE}} 
}
''';

  final String name;

  List<List<String>> _code;

  Map<String, List<String>> _constants;

  Map<String, List<String>> _constructors;

  Map<String, List<String>> _methods;

  Map<String, List<String>> _operators;

  Map<String, List<String>> _staticProperties;

  Map<String, List<String>> _staticMethods;

  Map<String, List<String>> _properties;

  Map<String, List<String>> _staticVariables;

  Map<String, List<String>> _variables;

  ClassGenerator(this.name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    addTemplate(_TEMPLATE, _template);
    _code = <List<String>>[];
    _constants = <String, List<String>>{};
    _constructors = <String, List<String>>{};
    _methods = <String, List<String>>{};
    _operators = <String, List<String>>{};
    _staticProperties = <String, List<String>>{};
    _staticMethods = <String, List<String>>{};
    _properties = <String, List<String>>{};
    _staticVariables = <String, List<String>>{};
    _variables = <String, List<String>>{};
  }

  void addCode(List<String> code) {
    if (code == null) {
      throw new ArgumentError("declaration: $code");
    }

    _code.add(code);
  }

  void addConstant(DeclarationGenerator declaration) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    _addDeclaration(declaration, _constants);
  }

  void addConstructor(DeclarationGenerator declaration) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    _addDeclaration(declaration, _constructors);
  }

  void addMethod(DeclarationGenerator declaration, [bool static = false]) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    if (static) {
      _addDeclaration(declaration, _staticMethods);
    } else {
      _addDeclaration(declaration, _methods);
    }
  }

  void addOperator(DeclarationGenerator declaration) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    _addDeclaration(declaration, _operators);
  }

  void addProperty(DeclarationGenerator declaration, [bool static = false]) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    if (static) {
      _addDeclaration(declaration, _staticProperties);
    } else {
      _addDeclaration(declaration, _properties);
    }
  }

  void addVariable(DeclarationGenerator declaration, [bool static = false]) {
    if (declaration == null) {
      throw new ArgumentError("declaration: $declaration");
    }

    if (static) {
      _addDeclaration(declaration, _staticVariables);
    } else {
      _addDeclaration(declaration, _variables);
    }
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("CLASSNAME", name);
    _generateDeclarations(block, "#CONSTANTS", _constants);
    _generateDeclarations(block, "#CONSTRUCTORS", _constructors);
    _generateDeclarations(block, "#METHODS", _methods);
    _generateDeclarations(block, "#OPERATORS", _operators);
    _generateDeclarations(block, "#PROPERTIES", _properties);
    _generateDeclarations(block, "#STATIC_METHODS", _staticMethods);
    _generateDeclarations(block, "#STATIC_PROPERTIES", _staticProperties);
    _generateDeclarations(block, "#STATIC_VARIABLES", _staticVariables);
    _generateDeclarations(block, "#VARIABLES", _variables);
    // User code
    for (var code in _code) {
      block.assign("#CODE", code);
    }

    return block.process();
  }

  void _addDeclaration(DeclarationGenerator generator, Map<String, List<String>> members) {
    var name = generator.name;
    if (members.containsKey(name)) {
      throw new StateError("Declaration generator with name '$name' already exists.");
    }

    members[name] = generator.generate();
  }

  void _generateDeclarations(TemplateBlock block, String key, Map<String, List<String>> members) {
    var names = members.keys.toList();
    names.sort((a, b) => a.compareTo(b));
    for (var name in names) {
      block.assign(key, members[name]);
    }
  }
}
