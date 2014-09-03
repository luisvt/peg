part of peg.grammar_analyzer;

class LeftRecursionsFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<ProductionRule>> result;

  Map<ProductionRule, List<List<Expression>>> find(List<ProductionRule> rules) {
    var map = new Map<ProductionRule, List<RuleExpression>>();
    for (var rule in rules) {
      var ruleExpression = rule.expression;
      var list = new List<RuleExpression>();
      //for(var expression in ruleExpression.allLeftExpressions) {
      for (var expression in ruleExpression.directLeftExpressions) {
        if (expression is RuleExpression) {
          list.add(expression);
        }
      }

      map[rule] = list;
    }

    var result = new Map<ProductionRule, List<List<Expression>>>();
    for (var rule in rules) {
      for (var left in map[rule]) {
        var recursion = _findRecursion(rule, left, new List(), map);
        if (recursion.length != 0) {
          result[rule] = recursion;
        }
      }
    }

    for (var rule in rules) {
      var paths = new List<List<String>>();
      paths.add(new List<String>());
      _findPath(rule, rule, paths, paths[0], new Set<ProductionRule>());
    }

    return result;
  }

  void _findPath(ProductionRule from, ProductionRule to, List<List<String>> paths, List<String> path, Set<ProductionRule> processed) {
    if (processed.contains(from)) {
      return;
    }

    processed.add(from);
    var fromExpression = from.expression;
    var toExpression = to.expression;
    if (!fromExpression.allLeftExpressions.contains(toExpression)) {
      return;
    }

    var rules = new Set<ProductionRule>();
    for (var expression in fromExpression.directLeftExpressions) {
      if (expression is RuleExpression) {
        var expressionRule = expression.rule;
        if (expression.allLeftExpressions.contains(toExpression) && expressionRule != null) {
          rules.add(expressionRule);
        }
      }
    }

    var length = rules.length;
    for (var i = 0; i < length; i++) {
      var rule = rules.elementAt(i);
      List<String> path2;
      if (i == 0) {
        path2 = path;
      } else {
        path2 = new List<String>();
        for (var item in path) {
          path2.add(item);
        }

        paths.add(path2);
      }

      path2.add(rule.name);
      _findPath(rule, to, paths, path2, processed);
    }
  }

  List _findRecursion(ProductionRule rule, RuleExpression expression, List<RuleExpression> processed, Map<ProductionRule, List<RuleExpression>> leftRules) {
    if (expression.rule == rule) {
      return [expression];
    }

    var before = new List();
    var lefts = leftRules[expression.rule];
    if (lefts != null) {
      for (var left in lefts) {
        if (!processed.contains(left)) {
          processed.add(left);
          var recursion = _findRecursion(rule, left, processed, leftRules);
          processed.remove(left);
          if (recursion.length != 0) {
            for (var cyclic in recursion) {
              var after = [expression];
              if (cyclic is List) {
                after.addAll(cyclic);
              } else {
                after.add(cyclic);
              }

              before.add(after);
            }
          }
        }
      }
    }

    return before;
  }
}
