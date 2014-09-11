part of peg.interpreter_parser_generator;

class InterpreterParserGenerator implements Generator {
  final Grammar grammar;

  final bool memoize;

  final String name;

  List<ProductionRuleInstruction> _entryPoints;

  InterpreterParserGenerator(this.name, this.grammar, {this.memoize: false}) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    if (memoize == null) {
      throw new ArgumentError("memoize: $memoize");
    }
  }

  List<String> generate() {
    _transformExpressions();
    _optimizeInstructions();
    List<String> topLevelCode;
    if (grammar.globals != null) {
      topLevelCode = Utils.codeToStrings(grammar.globals);
    }

    var generator = new InterpreterGenerator(name, _entryPoints, topLevelCode: topLevelCode);
    return generator.generate();
  }

  void _optimizeInstructions() {
    for (var i = 0; i < _entryPoints.length; i++) {
      var instruction = _entryPoints[i];
      var optimizer = new Optimizer();
      _entryPoints[i] = optimizer.optimize(instruction);
    }
  }

  void _transformExpressions() {
    _entryPoints = <ProductionRuleInstruction>[];
    for (var rule in grammar.rules) {
      if (rule.directCallers.isEmpty) {
        var transformer = new ProductionRuleInstructionBuilder(rule, trace: true);
        _entryPoints.add(transformer.transform());
      }
    }
  }
}
