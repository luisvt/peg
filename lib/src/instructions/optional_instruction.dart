part of peg.instructions;

class OptionalInstruction extends UnaryInstruction {
  OptionalInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.OPTIONAL;
}
