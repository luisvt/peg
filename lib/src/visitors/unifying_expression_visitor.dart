part of peg.visitors;

class UnifyingExpressionVisitor<T> extends ExpressionVisitor<T> {
  T visitAndPredicate(AndPredicateExpression expression) =>
      visitExpression(expression);

  T visitAnyCharacter(AnyCharacterExpression expression) =>
      visitExpression(expression);

  T visitCharacterClass(CharacterClassExpression expression) =>
      visitExpression(expression);

  T visitLiteral(LiteralExpression expression) => visitExpression(expression);

  T visitNotPredicate(NotPredicateExpression expression) =>
      visitExpression(expression);

  T visitOneOrMore(OneOrMoreExpression expression) =>
      visitExpression(expression);

  T visitOptional(OptionalExpression expression) => visitExpression(expression);

  T visitOrderedChoice(OrderedChoiceExpression expression) =>
      visitExpression(expression);

  T visitRule(RuleExpression expression) => visitExpression(expression);

  T visitSequence(SequenceExpression expression) => visitExpression(expression);

  T visitZeroOrMore(ZeroOrMoreExpression expression) =>
      visitExpression(expression);

  T visitExpression(Expression expression) {
    expression.visitChildren(this);
    return null;
  }
}
