part of peg.interpreter_parser.instructions;

class ZeroOrMoreInstruction extends UnaryInstruction {
  ZeroOrMoreInstruction(Instruction instruction) : super(instruction);

  ZeroOrMoreInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.ZERO_OR_MORE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitZeroOrMore(this);
  }
}
