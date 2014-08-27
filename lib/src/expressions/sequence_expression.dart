part of peg.expressions;

class SequenceExpression extends ListExpression {
  int _numberOfMayBeZero;

  SequenceExpression(List<Expression> expressions) : super(expressions) {
    for (var expression in expressions) {
      if (expression == null || expression is! Expression) {
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
      if (expression is ListExpression) {
        if (expression.isComplex) {
          strings.add('($expression)');
        } else {
          strings.add('$expression');
        }
      } else {
        strings.add('$expression');
      }
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
