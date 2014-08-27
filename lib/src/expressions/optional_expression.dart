part of peg.expressions;

class OptionalExpression extends SuffixExpression {
  OptionalExpression(Expression expression) : super(expression);

  String get suffix {
    return '?';
  }

  ExpressionTypes get type {
    return ExpressionTypes.OPTIONAL;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitOptional(this);
  }
}
