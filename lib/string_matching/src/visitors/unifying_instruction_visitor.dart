part of string_matching.visitors;

class UnifyingInstructionVisitor<T> implements InstructionVisitor<T> {
  T visitAndPredicate(AndPredicateInstruction instruction) => visitInstruction(instruction);

  T visitAnyCharacter(AnyCharacterInstruction instruction) => visitInstruction(instruction);

  T visitCharacterClass(CharacterClassInstruction instruction) => visitInstruction(instruction);

  T visitCharacter(CharacterInstruction instruction) => visitInstruction(instruction);

  T visitEmpty(EmptyInstruction instruction) => visitInstruction(instruction);

  T visitLiteral(LiteralInstruction instruction) => visitInstruction(instruction);

  T visitNotPredicate(NotPredicateInstruction instruction) => visitInstruction(instruction);

  T visitOneOrMore(OneOrMoreInstruction instruction) => visitInstruction(instruction);

  T visitOptional(OptionalInstruction instruction) => visitInstruction(instruction);

  T visitOrderedChoice(OrderedChoiceInstruction instruction) => visitInstruction(instruction);

  T visitProductionRule(ProductionRuleInstruction instruction) => visitInstruction(instruction);

  T visitRule(RuleInstruction instruction) => visitInstruction(instruction);

  T visitSequence(SequenceInstruction instruction) => visitInstruction(instruction);

  T visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction) => visitInstruction(instruction);

  T visitZeroOrMore(ZeroOrMoreInstruction instruction) => visitInstruction(instruction);

  T visitInstruction(Instruction instruction) {
    instruction.visitChildren(this);
    return null;
  }
}
