part of peg.interpreter_class_generator;

class InterpreterClassGenerator {
  static const String VARIABLE_INPUT = "_input";

  static const String VARIABLE_INPUT_LEN = "_inputLen";

  final Grammar grammar;

  final String name;

  final InterpreterGenerator interpreterGenerator;

  Map<String, _InterpreterEntry> _entries;

  Map<int, List<String>> _intructionStates;

  int _interrupt;

  InterpreterClassGenerator(this.name, this.grammar, this.interpreterGenerator) {
    _interrupt = -1;
    _intructionStates = <int, List<String>>{};
  }

  int registerInterrupts(int count) {
    if (count == null || count <= 0) {
      throw new ArgumentError("count: $count");
    }

    var interrupt = _interrupt;
    _interrupt -= count;
    return interrupt;
  }

  List<String> generate() {
    _entries = <String, _InterpreterEntry>{};
    _transformExpressions();
    _compileInstructions();
    var constructors = <String>[];
    var methods = <String>[];
    var properties = <String>[];
    var variables = <String>[];
    _generateVariables(variables);
    _generateMethods(methods);
    _generateMethodParse(methods);
    _writeInterpreters(methods, variables);
    var classGenerator = new ClassGenerator(constructors: constructors, methods: methods, name: name, properties: properties, variables: variables);
    return classGenerator.generate();
  }

  void _compileInstructions() {
    for (var key in _entries.keys) {
      var entry = _entries[key];
      var instructions = entry.instructions;
      var compiler = new InstructionCompiler();
      var code = <int>[];
      var data = [];
      compiler.compile(instructions, code, data);
      entry.code = code;
      entry.data = data;
    }
  }

  void _generateMethodParse(List<String> methods) {
    var generator = new MethodParseGenerator(this);
    var method = generator.generate();
    methods.addAll(method);
  }

  void _generateMethods(List<String> methods) {
    var generators = <Generator>[];
    generators.add(new ClassContructorGenerator(name));
    for (var generator in generators) {
      methods.addAll(generator.generate());
    }
  }

  // TODO:
  void _generateSemanticActions() {
  }

  void _generateVariables(List<String> variables) {
    variables.add("String $VARIABLE_INPUT;");
    variables.add("int $VARIABLE_INPUT_LEN;");
  }

  void _transformExpressions() {
    for (var rule in grammar.rules) {
      if (rule.directCallers.isEmpty) {
        var transformer = new InstructionFromExpressionTransformer(rule);
        var instructions = transformer.transform();
        var entry = new _InterpreterEntry();
        var name = rule.name;
        entry.name = name;
        entry.instructions = instructions;
        _entries[name] = entry;
      }
    }
  }

  void _writeInterpreters(List<String> methods, List<String> variables) {
    for (var key in _entries.keys) {
      var entry = _entries[key];
      var name = camelize(key, true);
      var code = entry.code;
      var list = <String>[];
      for (var element in code) {
        var dec = element.toString();
        var hex = "0x" + element.toRadixString(16);
        if (dec.length <= hex.length) {
          list.add(dec);
        } else {
          list.add(hex);
        }
      }

      var variable = "List<int> _${name}Code = [${list.join(", ")}];";
      variables.add(variable);
      var data = entry.data;
      list = <String>[];
      for (var element in data) {
        if (element is int) {
          var dec = element.toString();
          var hex = "0x" + element.toRadixString(16);
          if (dec.length <= hex.length) {
            list.add(dec);
          } else {
            list.add(hex);
          }
        } else if (element is String) {
          list.add("\"${escape(element)}\"");
        } else {
          throw new StateError("Unsupported data type '${element.runtimeType}'");
        }
      }

      variable = "List<int> _${name}Data = [${list.join(", ")}];";
      variables.add(variable);
      var method = new MethodParseEntryGenerator(key).generate();
      methods.addAll(method);
    }
  }
}

class _InterpreterEntry {
  List<int> code;

  List data;

  String name;

  List<Instruction> instructions;
}
