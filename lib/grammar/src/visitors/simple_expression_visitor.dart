part of peg.grammar.expression_visitors;

class SimpleExpressionVisitor<T> extends ExpressionVisitor<T> {
  T visitAndPredicate(AndPredicateExpression expression) => null;

  T visitAnyCharacter(AnyCharacterExpression expression) => null;

  T visitCharacterClass(CharacterClassExpression expression) => null;

  T visitLiteral(LiteralExpression expression) => null;

  T visitNotPredicate(NotPredicateExpression expression) => null;

  T visitOneOrMore(OneOrMoreExpression expression) => null;

  T visitOptional(OptionalExpression expression) => null;

  T visitOrderedChoice(OrderedChoiceExpression expression) => null;

  T visitRule(RuleExpression expression) => null;

  T visitSequence(SequenceExpression expression) => null;

  T visitZeroOrMore(ZeroOrMoreExpression expression) => null;
}
