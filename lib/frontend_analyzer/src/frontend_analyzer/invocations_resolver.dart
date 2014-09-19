part of peg.frontend_analyzer.frontend_analyzer;

class InvocationsResolver extends UnifyingExpressionVisitor {
  bool prepare;

  InvocationsResolver(this.prepare);

  Object visitRule(RuleExpression expression) {
    var callee = expression.rule;
    var caller = expression.owner;
    if (callee != null && caller != null) {
      if (prepare) {
        callee.directCallers.add(caller);
        caller.directCallees.add(callee);
      } else {
        ProductionRule.addCalls(caller, callee, true);
      }
    }

    return null;
  }
}
