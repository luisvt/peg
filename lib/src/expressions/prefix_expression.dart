part of peg.expressions;

abstract class PrefixExpression extends UnaryExpression {
  String get prefix;

  PrefixExpression(Expression expression) : super(expression);

  String toString() {
    if (expression is ListExpression) {
      if ((expression as ListExpression).isComplex) {
        return '$prefix($expression)';
      }
    }

    return '$prefix$expression';
  }
}
