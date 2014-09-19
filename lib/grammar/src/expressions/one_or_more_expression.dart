part of peg.grammar.expressions;

class OneOrMoreExpression extends SuffixExpression {
  OneOrMoreExpression(Expression expression) : super(expression);

  String get suffix {
    return '+';
  }

  ExpressionTypes get type {
    return ExpressionTypes.ONE_OR_MORE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitOneOrMore(this);
  }
}
