part of peg.interpreter_parser.instructions;

class AndPredicateInstruction extends UnaryInstruction {
  AndPredicateInstruction(Instruction instruction) : super(instruction);

  AndPredicateInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.AND_PREDICATE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitAndPredicate(this);
  }
}
