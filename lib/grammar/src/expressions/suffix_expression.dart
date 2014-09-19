part of peg.grammar.expressions;

abstract class SuffixExpression extends UnaryExpression {
  String get suffix;

  SuffixExpression(Expression expression) : super(expression);

  String toString() {
    if (expression is ListExpression) {
      if ((expression as ListExpression).isComplex) {
        return '($expression)$suffix';
      }
    }

    return '$expression$suffix';
  }
}
