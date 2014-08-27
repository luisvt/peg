part of peg.expressions;

class AnyCharacterExpression extends Expression {
  AnyCharacterExpression() : super();

  ExpressionTypes get type {
    return ExpressionTypes.ANY_CHARACTER;
  }

  String toString() {
    return '.';
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitAnyCharacter(this);
  }

  Object visitChildren(ExpressionVisitor visitor) {
    return this;
  }
}
