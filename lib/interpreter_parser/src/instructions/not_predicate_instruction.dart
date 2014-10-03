part of peg.interpreter_parser.instructions;

class NotPredicateInstruction extends UnaryInstruction {
  NotPredicateInstruction(Instruction instruction) : super(instruction);

  NotPredicateInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.NOT_PREDICATE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitNotPredicate(this);
  }
}
