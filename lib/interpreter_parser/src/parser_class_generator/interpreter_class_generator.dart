part of peg.interpreter_parser.parser_class_generator;

class InterpreterClassGenerator extends ParserClassGenerator {
  static const String CODE = "_code";

  static const String DATA = "_data";

  static const String RESULT = "_result";

  final Grammar grammar;

  final ParserGenerator parserGenerator;

  Map<String, Instruction> _entryPoints;

  Map<int, List<String>> _instructionStates;

  InterpreterClassGenerator(String name, this.grammar, this.parserGenerator, Map<String, Instruction> entryPoints) : super(name) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    if (entryPoints == null) {
      throw new ArgumentError("entryPoints: $entryPoints");
    }

    _entryPoints = entryPoints;
    _instructionStates = <int, List<String>>{};
  }

  ParserGeneratorOptions get options => parserGenerator.options;

  List<String> generate() {
    _generateConstructors();
    _generateVariables();
    _generateDecoders();
    _generateMethods();
    _writeEntryPoints();
    _generateSemanticActions();
    return super.generate();
  }

  void _generateDecoders() {
    var generators = <DecoderGenerator>[];
    generators.add(new AndPredicateDecoderGenerator());
    generators.add(new AnyCharacterDecoderGenerator());
    generators.add(new CharacterClassDecoderGenerator());
    generators.add(new CharacterDecoderGenerator());
    generators.add(new EmptyDecoderGenerator());
    generators.add(new LiteralDecoderGenerator());
    generators.add(new NotPredicateDecoderGenerator());
    generators.add(new OneOrMoreDecoderGenerator());
    generators.add(new OptionalDecoderGenerator());
    generators.add(new OrderedChoiceDecoderGenerator());
    generators.add(new ProductionRuleDecoderGenerator());
    generators.add(new RuleDecoderGenerator());
    generators.add(new SequenceDecoderGenerator());
    generators.add(new SequenceWithOneElementDecoderGenerator());
    generators.add(new ZeroOrMoreDecoderGenerator());
    for (var generator in generators) {
      addMethod(generator);
    }

    addMethod(new MethodDecodeGenerator(this, generators));
  }

  void _generateConstructors() {
    addConstructor(new ClassContructorGenerator(name));
  }

  void _generateMethods() {
    addMethod(new MethodParseGenerator());
  }

  void _generateSemanticActions() {
    var generator = new SemanticActionGenerator();
    generator.generate(_entryPoints, this);
  }

  void _generateVariables() {
    addVariable(new VariableGenerator(RESULT, "Object"));
  }

  String _listToString(List list, [String separator = ", "]) {
    var strings = <String>[];
    for (var element in list) {
      if (element is List) {
        strings.add(_listToString(element));
      } else if (element is String) {
        strings.add("\"${escape(element)}\"");
      } else {
        strings.add(element.toString());
      }
    }

    return "[${strings.join(separator)}]";
  }

  void _writeEntryPoints() {
    var code = <int>[];
    var data = [];
    for (var name in _entryPoints.keys) {
      var instruction = _entryPoints[name];
      var optimizer = new Optimizer();
      instruction = optimizer.optimize(instruction);
      _entryPoints[name] = instruction;
      var compiler = new Compiler();
      compiler.compile(instruction, code, data);
      for (var element in data) {
        if (element is int || element is String || element is List) {
        } else {
          throw new StateError("Unsupported data type '${element.runtimeType}'");
        }
      }

      addMethod(new MethodParseEntryGenerator(instruction, name));
    }

    addVariable(new VariableGenerator(CODE, "List<int>", value: "[${code.join(", ")}]"));
    addVariable(new VariableGenerator(DATA, "List", value: _listToString(data)));
  }
}
