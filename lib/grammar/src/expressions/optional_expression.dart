part of peg.grammar.expressions;

class OptionalExpression extends SuffixExpression {
  OptionalExpression(Expression expression) : super(expression);

  int get minTimes => 0;

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
