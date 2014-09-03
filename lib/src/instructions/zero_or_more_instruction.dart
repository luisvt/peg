part of peg.instructions;

class ZeroOrMoreInstruction extends UnaryInstruction {
  ZeroOrMoreInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.ZERO_OR_MORE;
}
