part of peg.expressions;

class OrderedChoiceExpression extends ListExpression {
  int lookaheadId = -1;

  OrderedChoiceExpression(List<Expression> expressions) : super(expressions) {
    for (var expression in expressions) {
      if (expression is! SequenceExpression) {
        throw new StateError('The expression list contains illegal expression.');
      }
    }
  }

  List<Expression> get expressions {
    return super.expressions;
  }

  ExpressionTypes get type {
    return ExpressionTypes.ORDERED_CHOICE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitOrderedChoice(this);
  }

  String toString() {
    return _expressions.toList().join(' / ');
  }

  Object visitChildren(ExpressionVisitor visitor) {
    for (var expression in expressions) {
      expression.accept(visitor);
    }

    return this;
  }
}
