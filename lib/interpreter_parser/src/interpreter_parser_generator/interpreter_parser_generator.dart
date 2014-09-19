part of peg.interpreter_parser.parser_generator;

class InterpreterParserGenerator implements Generator {
  final Grammar grammar;

  final bool memoize;

  final String name;

  Map<String, Instruction> _entryPoints;

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
    List<String> topLevelCode;
    if (grammar.globals != null) {
      topLevelCode = Utils.codeToStrings(grammar.globals);
    }

    var generator = new InterpreterGenerator(name, _entryPoints, topLevelCode: topLevelCode);
    return generator.generate();
  }

  void _transformExpressions() {
    _entryPoints = <String, Instruction>{};
    for (var rule in grammar.rules) {
      if (rule.isStartingRule) {
        var transformer = new ProductionRuleInstructionBuilder(rule);
        _entryPoints[rule.name] = transformer.transform();
      }
    }
  }
}
