part of peg.interpreter_parser_generator;

class ProductionRuleInstructionBuilder {
  final bool trace;

  final ProductionRule productionRule;

  ProductionRuleInstructionBuilder(this.productionRule, {this.trace: false}) {
    if (productionRule == null) {
      new ArgumentError("productionRule: $productionRule");
    }

    if (trace == null) {
      throw new ArgumentError("trace: $trace");
    }
  }

  ProductionRuleInstruction transform() {
    var visitor = new ExpressionConverter();
    var instruction = productionRule.expression.accept(visitor);
    // TODO: ProductionRuleInstruction
    return instruction;
  }
}
