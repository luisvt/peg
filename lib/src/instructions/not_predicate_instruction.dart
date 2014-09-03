part of peg.instructions;

class NotPredicateInstruction extends UnaryInstruction {
  NotPredicateInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.NOT_PREDICATE;
}
