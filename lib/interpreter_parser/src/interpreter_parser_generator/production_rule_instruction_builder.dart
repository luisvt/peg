part of peg.interpreter_parser.parser_generator;

class ProductionRuleInstructionBuilder {

  final ProductionRule productionRule;

  ProductionRuleInstructionBuilder(this.productionRule) {
    if (productionRule == null) {
      new ArgumentError("productionRule: $productionRule");
    }
  }

  ProductionRuleInstruction transform() {
    var visitor = new ExpressionConverter();
    var instruction = productionRule.expression.accept(visitor);
    // TODO: ProductionRuleInstruction
    return instruction;
  }
}
