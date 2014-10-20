part of peg.grammar.expressions;

class ZeroOrMoreExpression extends SuffixExpression {
  ZeroOrMoreExpression(Expression expression) : super(expression);

  int get minTimes => 0;

  int get maxTimes => null;

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
