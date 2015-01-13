part of peg.interpreter_parser.instructions;

class OptionalInstruction extends UnaryInstruction {
  OptionalInstruction(Instruction instruction) : super(instruction);

  OptionalInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.OPTIONAL;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitOptional(this);
  }
}
