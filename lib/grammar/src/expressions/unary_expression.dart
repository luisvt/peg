part of peg.grammar.expressions;

abstract class UnaryExpression extends Expression {
  Expression _expression;

  UnaryExpression(Expression expression) : super() {
    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    _expression = expression;
  }

  Expression get expression {
    return _expression;
  }

  Object visitChildren(ExpressionVisitor visitor) {
    expression.accept(visitor);
    return this;
  }
}
