part of peg.grammar.expressions;

abstract class PrefixExpression extends UnaryExpression {
  String get prefix;

  PrefixExpression(Expression expression) : super(expression);

  String toString() {
    return '$prefix$expression';
  }
}
