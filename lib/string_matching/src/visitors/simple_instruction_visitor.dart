part of string_matching.visitors;

class SimpleInstructionVisitor<T> implements InstructionVisitor<T> {
  T visitAndPredicate(AndPredicateInstruction instruction) => null;

  T visitAnyCharacter(AnyCharacterInstruction instruction) => null;

  T visitCharacterClass(CharacterClassInstruction instruction) => null;

  T visitCharacter(CharacterInstruction instruction) => null;

  T visitEmpty(EmptyInstruction instruction) => null;

  T visitLiteral(LiteralInstruction instruction) => null;

  T visitNotPredicate(NotPredicateInstruction instruction) => null;

  T visitOneOrMore(OneOrMoreInstruction instruction) => null;

  T visitOptional(OptionalInstruction instruction) => null;

  T visitOrderedChoice(OrderedChoiceInstruction instruction) => null;

  T visitProductionRule(ProductionRuleInstruction instruction) => null;

  T visitRule(RuleInstruction instruction) => null;

  T visitSequence(SequenceInstruction instruction) => null;

  T visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction) => null;

  T visitZeroOrMore(ZeroOrMoreInstruction instruction) => null;
}
