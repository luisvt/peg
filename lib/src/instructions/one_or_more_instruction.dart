part of peg.instructions;

class OneOrMoreInstruction extends UnaryInstruction {
  OneOrMoreInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.ONE_OR_MORE;
}
