part of peg.instructions;

class SequenceInstruction extends Instruction {
  static const int OFFSET_INSTRUCTION_COUNT = 0;

  static const int OFFSET_INSTRUCTIONS = 1;

  List<Instruction> instructions;

  SequenceInstruction(this.instructions) {
    if (instructions == null) {
      throw new ArgumentError("instructions: $instructions");
    }
  }

  InstructionTypes get type => InstructionTypes.SEQUENCE;
}
