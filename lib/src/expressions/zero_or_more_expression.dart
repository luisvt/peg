part of peg.expressions;

class ZeroOrMoreExpression extends SuffixExpression {
  ZeroOrMoreExpression(Expression expression) : super(expression);

  String get suffix {
    return '*';
  }

  ExpressionTypes get type {
    return ExpressionTypes.ZERO_OR_MORE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitZeroOrMore(this);
  }
}
