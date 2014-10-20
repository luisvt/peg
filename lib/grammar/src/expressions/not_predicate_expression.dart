part of peg.grammar.expressions;

class NotPredicateExpression extends PrefixExpression {
  NotPredicateExpression(Expression expression) : super(expression);

  String get prefix {
    return '!';
  }

  int get maxTimes => 1;

  int get minTimes => 1;

  ExpressionTypes get type {
    return ExpressionTypes.NOT_PREDICATE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitNotPredicate(this);
  }
}
