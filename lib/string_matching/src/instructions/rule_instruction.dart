part of string_matching.instructions;

class RuleInstruction extends Instruction {
  Instruction instruction;

  String name;

  RuleInstruction(this.name, this.instruction) {
    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }
  }

  RuleInstruction.parameterized({List<String> action, this.instruction, this.name}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.RULE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitRule(this);
  }

  Object visitChildren(InstructionVisitor visitor) {
    return instruction.accept(visitor);
  }
}
