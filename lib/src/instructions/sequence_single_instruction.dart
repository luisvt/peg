part of peg.instructions;

class SequenceSingleInstruction extends UnaryInstruction {
  static const int OFFSET_INSTRUCTION = 0;

  SequenceSingleInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.SEQUENCE_SINGLE;
}
