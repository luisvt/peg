part of peg.grammar.expressions;

class NotPredicateExpression extends PrefixExpression {
  NotPredicateExpression(Expression expression) : super(expression);

  String get prefix {
    return '!';
  }

  ExpressionTypes get type {
    return ExpressionTypes.NOT_PREDICATE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitNotPredicate(this);
  }
}
