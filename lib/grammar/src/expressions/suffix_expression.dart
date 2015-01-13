part of peg.grammar.expressions;

abstract class SuffixExpression extends UnaryExpression {
  String get suffix;

  SuffixExpression(Expression expression) : super(expression);

  String toString() {
    return '$expression$suffix';
  }
}
