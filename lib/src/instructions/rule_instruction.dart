part of peg.instructions;

class RuleInstruction extends Instruction {
  Instruction instruction;

  String name;

  RuleInstruction(this.name, this.instruction) {
    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }
  }

  InstructionTypes get type => InstructionTypes.RULE;
}
