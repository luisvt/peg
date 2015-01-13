part of peg.interpreter_parser.instructions;

class OneOrMoreInstruction extends UnaryInstruction {
  OneOrMoreInstruction(Instruction instruction) : super(instruction);

  OneOrMoreInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.ONE_OR_MORE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitOneOrMore(this);
  }
}
