part of peg.frontend_analyzer.frontend_analyzer;

class ExpressionOwnershipResolver extends UnifyingExpressionVisitor {
  visitExpression(Expression expression) {
    var parent = expression.parent;
    if (parent != null) {
      expression.owner = parent.owner;
    }

    return super.visitExpression(expression);
  }
}
