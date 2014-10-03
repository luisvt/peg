part of peg.interpreter_parser.visitors;

abstract class InstructionVisitor<T> {
  T visitAndPredicate(AndPredicateInstruction instruction);

  T visitAnyCharacter(AnyCharacterInstruction instruction);

  T visitCharacterClass(CharacterClassInstruction instruction);

  T visitCharacter(CharacterInstruction instruction);

  T visitEmpty(EmptyInstruction instruction);

  T visitLiteral(LiteralInstruction instruction);

  T visitNotPredicate(NotPredicateInstruction instruction);

  T visitOneOrMore(OneOrMoreInstruction instruction);

  T visitOptional(OptionalInstruction instruction);

  T visitOrderedChoice(OrderedChoiceInstruction instruction);

  T visitProductionRule(ProductionRuleInstruction instruction);

  T visitRule(RuleInstruction instruction);

  T visitSequence(SequenceInstruction instruction);

  T visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction);

  T visitZeroOrMore(ZeroOrMoreInstruction instruction);
}
