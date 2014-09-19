part of peg.frontend_analyzer.frontend_analyzer;

// TODO: remove? if levels not used
class ExpressionLevelResolver extends UnifyingExpressionVisitor {
  int level;

  int levels;

  Set<Expression> processed;

  void levelDown() {
    level--;
  }

  int levelUp() {
    level++;
    if (level > levels) {
      levels++;
    }

    return level;
  }

  int resolve(List<ProductionRule> rules) {
    level = 0;
    levels = 0;
    processed = new Set<Expression>();
    for (var rule in rules) {
      rule.expression.accept(this);
    }

    return levels;
  }

  Object visitAndPredicate(AndPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    if (expression.level < child.level) {
      expression.level = child.level;
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    if (expression.level < child.level) {
      expression.level = child.level;
    }

    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    if (expression.level < child.level) {
      expression.level = child.level;
    }

    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    var child = expression.expression;
    child.accept(this);
    if (expression.level < child.level) {
      expression.level = child.level;
    }

    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      if (expression.level < child.level) {
        expression.level = child.level;
      }
    }

    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      expression.level = levelUp();
      ruleExpression.accept(this);
      if (expression.level < ruleExpression.level) {
        expression.level = ruleExpression.level;
      }

      levelDown();
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    for (var child in expression.expressions) {
      child.accept(this);
      if (expression.level < child.level) {
        expression.level = child.level;
      }
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    var child = expression.expression;
    child.accept(this);
    if (expression.level < child.level) {
      expression.level = child.level;
    }

    return null;
  }
}
