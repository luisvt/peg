part of peg.frontend_analyzer;

class ExpressionHierarchyResovler extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _setParent(expression);
    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    _setParent(expression);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _setParent(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    _setParent(expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    Expression previous;
    for (var child in expression.expressions) {
      child.parent = expression;
      child.positionInSequence = expression.positionInSequence;
      child.previous = previous;
      if (previous != null) {
        previous.next = child;
      }

      child.accept(this);
      previous = child;
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var index = 0;
    Expression previous;
    for (var child in expression.expressions) {
      child.parent = expression;
      child.positionInSequence = index++;
      child.previous = previous;
      if (previous != null) {
        previous.next = child;
      }

      previous = child;
      child.accept(this);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    _setParent(expression);
    return null;
  }

  Object _setParent(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    child.parent = expression;
    return null;
  }
}
