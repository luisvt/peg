part of peg.interpreter_parser.instructions;

class ProductionRuleInstruction extends Instruction {
  static const int STRUCT_PRODUCTION_RULE_INSTRUCTION = 0;

  static const int STRUCT_PRODUCTION_RULE_ID = 1;

  static const int STRUCT_PRODUCTION_TOKEN_ID = 2;

  static const int SIZE_OF_STRUCT_PRODUCTION_RULE = 3;

  int id;

  Instruction instruction;

  bool memoize;

  String name;

  int tokenId;

  ProductionRuleInstruction(this.id, this.name, this.instruction, this.memoize) {
    if (id == null) {
      throw new ArgumentError("id: $id");
    }

    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }

    if (memoize == null) {
      throw new ArgumentError("memoize: $memoize");
    }
  }

  ProductionRuleInstruction.parameterized({List<String> action, this.id, this.instruction, this.memoize, this.name, this.tokenId}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.PRODUCTION_RULE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitProductionRule(this);
  }

  Object visitChildren(InstructionVisitor visitor) {
    return instruction.accept(visitor);
  }
}
