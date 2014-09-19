part of peg.grammar_analyzer.grammar_analyzer;

class ChoiceWithOptionalFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<Expression>> result;

  Map<ProductionRule, List<Expression>> find(List<ProductionRule> rules) {
    result = new Map<ProductionRule, List<Expression>>();
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    return result;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    var expressions = expression.expressions;
    if (expressions.length == 1) {
      return null;
    }

    for (var child in expressions) {
      if (child.isOptional) {
        var owner = expression.owner;
        var list = result[owner];
        if (list == null) {
          list = new List<Expression>();
          result[owner] = list;
        }

        list.add(child);
      }
    }

    return null;
  }
}
