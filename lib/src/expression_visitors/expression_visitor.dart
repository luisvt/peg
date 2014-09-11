part of peg.expression_visitors;

abstract class ExpressionVisitor<T> {
  T visitAndPredicate(AndPredicateExpression expression);

  T visitAnyCharacter(AnyCharacterExpression expression);

  T visitCharacterClass(CharacterClassExpression expression);

  T visitLiteral(LiteralExpression expression);

  T visitNotPredicate(NotPredicateExpression expression);

  T visitOneOrMore(OneOrMoreExpression expression);

  T visitOptional(OptionalExpression expression);

  T visitOrderedChoice(OrderedChoiceExpression expression);

  T visitRule(RuleExpression expression);

  T visitSequence(SequenceExpression expression);

  T visitZeroOrMore(ZeroOrMoreExpression expression);
}
