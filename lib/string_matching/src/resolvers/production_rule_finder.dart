part of string_matching.resolvers;

class ProductionRuleFinder extends UnifyingInstructionVisitor {
  List<ProductionRuleInstruction> productionRules;

  Set<ProductionRuleInstruction> _visited;

  ProductionRuleFinder(Instruction instruction) {
    _visited = new Set<ProductionRuleInstruction>();
    instruction.accept(this);
    productionRules = _visited.toList();
  }

  visitProductionRule(ProductionRuleInstruction instruction) {
    if (_visited.contains(instruction)) {
      return instruction;
    }

    _visited.add(instruction);
    instruction.instruction.accept(this);
    return instruction;
  }
}
