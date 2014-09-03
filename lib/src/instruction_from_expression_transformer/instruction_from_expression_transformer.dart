part of peg.instruction_from_expression_transformer;

class InstructionFromExpressionTransformer {
  final ProductionRule productionRule;

  InstructionFromExpressionTransformer(this.productionRule) {
    if (productionRule == null) {
      new ArgumentError("productionRule: $productionRule");
    }
  }

  List<Instruction> transform() {
    var visitor = new ExpressionToInstructionVisitor();
    productionRule.expression.accept(visitor);
    return visitor.instructions;
  }
}
