part of peg.grammar.expressions;

class SequenceExpression extends ListExpression {
  int _numberOfMayBeZero;

  SequenceExpression(List<Expression> expressions) : super(expressions) {
    for (var expression in expressions) {
      if (expression == null || expression is! Expression || expression is SequenceExpression) {
        throw new StateError('The expression list contains illegal expression');
      }
    }

    _numberOfMayBeZero = expressions.length;
  }

  ExpressionTypes get type {
    return ExpressionTypes.SEQUENCE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitSequence(this);
  }

  String toString() {
    var strings = [];
    for (var expression in _expressions) {
      strings.add('$expression');
    }

    return strings.join(' ');
  }

  Object visitChildren(ExpressionVisitor visitor) {
    for (var expression in expressions) {
      expression.accept(visitor);
    }

    return this;
  }
}
