part of peg.grammar.expressions;

abstract class ListExpression extends Expression {
  List<Expression> _expressions;

  ListExpression(List<Expression> expressions) : super() {
    if (expressions == null) {
      throw new ArgumentError('expressions: $expressions');
    }

    if (expressions.length == 0) {
      throw new StateError('The expression list contains no elements');
    }

    _expressions = expressions;
  }

  List<Expression> get expressions {
    return _expressions;
  }
}
