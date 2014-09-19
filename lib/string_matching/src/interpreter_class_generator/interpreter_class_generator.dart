part of string_matching.interpreter_class_generator;

class InterpreterClassGenerator {
  static const String _ASCII = GlobalNaming.ASCII;

  static const String _CH = GlobalNaming.CH;

  static const String _CACHE = GlobalNaming.CACHE;

  static const String _CACHE_POS = GlobalNaming.CACHE_POS;

  static const String _CACHE_RULE = GlobalNaming.CACHE_RULE;

  static const String _CACHE_STATE = GlobalNaming.CACHE_STATE;

  static const String _CODE = GlobalNaming.CODE;

  static const String _COLUMN = GlobalNaming.COLUMN;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _DATA = GlobalNaming.DATA;

  static const String _EXPECTED = GlobalNaming.EXPECTED;

  static const String _FAILURE_POS = GlobalNaming.FAILURE_POS;

  static const String _FLAG = GlobalNaming.FLAG;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _LINE = GlobalNaming.LINE;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TESTING = GlobalNaming.TESTING;

  final String name;

  List<String> _classLevelCode;

  Map<String, List<String>> _constructors;

  Map<String, Instruction> _entryPoints;

  Map<int, List<String>> _instructionStates;

  Map<String, List<String>> _methods;

  Map<String, List<String>> _mutators;

  Map<String, List<String>> _variables;

  InterpreterClassGenerator(this.name, Map<String, Instruction> entryPoints, {List<String> classLevelCode, bool memoize: false}) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    if (entryPoints == null) {
      throw new ArgumentError("entryPoints: $entryPoints");
    }

    _classLevelCode = classLevelCode;
    _entryPoints = entryPoints;
    _instructionStates = <int, List<String>>{};
  }

  void _addVariable(String name, String type, [String initializtion]) {
    var sb = new StringBuffer();
    sb.write(type);
    sb.write(" ");
    sb.write(name);
    if (initializtion != null) {
      sb.write(" = ");
      sb.write(initializtion);
    }

    sb.write(";");

    _variables[name] = [sb.toString()];
  }

  List<String> generate() {
    _constructors = <String, List<String>>{};
    _methods = <String, List<String>>{};
    _mutators = <String, List<String>>{};
    _variables = <String, List<String>>{};
    _generateConstructors();
    _generateVariables();
    _generateDecoders();
    _generateMethods();
    _writeEntryPoints();
    _generateSemanticActions();
    var constructors = _mapToSortedLists(_constructors);
    var methods = _mapToSortedLists(_methods);
    var mutators = _mapToSortedLists(_mutators);
    var variables = _mapToSortedLists(_variables);
    var classLevelCode = <List<String>>[];
    if (_classLevelCode != null) {
      classLevelCode.add(_classLevelCode);
    }

    var classGenerator = new ClassGenerator(code: classLevelCode, constructors: constructors, methods: methods, mutators: mutators, name: name, variables: variables);
    return classGenerator.generate();
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
      _generateMethod(generator);
    }

    _generateMethod(new MethodDecodeGenerator(this, generators));
  }

  void _generateMethod(MethodGenerator generator) {
    _methods[generator.name] = generator.generate();
  }

  void _generateConstructors() {
    _constructors[name] = new ClassContructorGenerator(name).generate();
  }

  void _generateMethods() {
    /**
    var productionRules = <ProductionRuleInstruction>[];
    // TODO: Memoization
    for (var instruction in _entryPoints) {
      var resolver = new ProductionRuleFinder(instruction);
      // productionRules.addAll(resolver.productionRules.where((r) => r.memoize));
      productionRules.addAll(resolver.productionRules);
    }

    // Cache
    var size = (productionRules.length >> 5) + 1;
    if (size != size << 5) {
      size++;
    }
    */

    int size = 0;
    _generateMethod(new AccessorColumnGenerator());
    _generateMethod(new AccessorLineGenerator());
    _generateMethod(new AcessorUnexpectedGenerator());
    _generateMethod(new MethodAddToCacheGenerator(size));
    _generateMethod(new MethodCalculatePosGenerator());
    _generateMethod(new MethodCompactGenerator());
    _generateMethod(new MethodExpectedGenerator());
    _generateMethod(new MethodGetFromCacheGenerator());
    _generateMethod(new MethodFlattenGenerator());
    _generateMethod(new MethodParseGenerator());
    _generateMethod(new MethodResetGenerator());
    _generateMethod(new MethodToRunesGenerator());
    _generateMethod(new MethodToRuneGenerator());
  }

  void _generateSemanticActions() {
    for (var instruction in _entryPoints.values) {
      var generator = new SemanticActionGenerator();
      generator.generate(instruction, _methods);
    }
  }

  void _generateVariables() {
    _addVariable(_ASCII, "static final List<String>", "new List<String>.generate(128, (c) => new String.fromCharCode(c))");
    _addVariable(_CACHE, "List");
    _addVariable(_CACHE_POS, "int");
    _addVariable(_CACHE_RULE, "List<int>");
    _addVariable(_CACHE_STATE, "List<int>");
    _addVariable(_CH, "int");
    _addVariable(_CODE, "List<int>");
    _addVariable(_COLUMN, "int");
    _addVariable(_CURSOR, "int");
    _addVariable(_DATA, "List");
    _addVariable(_EXPECTED, "List<String>");
    _addVariable(_FAILURE_POS, "int");
    _addVariable(_FLAG, "int");
    _addVariable(_INPUT_LEN, "int");
    _addVariable(_LINE, "int");
    _addVariable(_RESULT, "Object");
    _addVariable(_RUNES, "List<int>");
    _addVariable(_SUCCESS, "bool");
    _addVariable(_TESTING, "int");
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

  List<List<String>> _mapToSortedLists(Map<String, List<String>> map) {
    var result = <List<String>>[];
    var keys = map.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    for (var key in keys) {
      result.add(map[key]);
    }

    return result;
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

      _generateMethod(new MethodParseEntryGenerator(instruction, name));
    }

    _addVariable(_CODE, "List<int>", "[${code.join(", ")}]");
    _addVariable(_DATA, "List", _listToString(data));
  }
}
