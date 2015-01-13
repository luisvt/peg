part of peg.interpreter_parser.parser_generator;

class InterpreterParserGenerator extends ParserGenerator {
  InterpreterParserGenerator(String name, Grammar grammar, ParserGeneratorOptions options) : super(name, grammar, options);

  List<String> generate() {
    _transformExpressions();
    return super.generate();
  }

  void _transformExpressions() {
    var entryPoints = <String, Instruction>{};
    for (var rule in grammar.productionRules) {
      if (rule.isStartingRule) {
        var transformer = new ProductionRuleInstructionBuilder(rule);
        entryPoints[rule.name] = transformer.transform();
      }
    }

    addClass(new InterpreterClassGenerator(name, grammar, this, entryPoints));
  }
}
