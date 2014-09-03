part of peg.instructions;

class AndPredicateInstruction extends UnaryInstruction {
  AndPredicateInstruction(Instruction instruction) : super(instruction);

  InstructionTypes get type => InstructionTypes.AND_PREDICATE;
}
