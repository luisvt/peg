part of peg.grammar.expressions;

class AndPredicateExpression extends PrefixExpression {
  AndPredicateExpression(Expression expression) : super(expression);

  String get prefix {
    return '&';
  }

  ExpressionTypes get type {
    return ExpressionTypes.AND_PREDICATE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitAndPredicate(this);
  }
}
