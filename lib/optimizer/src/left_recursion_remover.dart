part of peg.optimizer;

class LeftRecursionRemover {
  List<ProductionRule> remove(List<ProductionRule> rules) {
    if (rules == null) {
      throw new ArgumentError.notNull("rules");
    }

    var result = <ProductionRule>[];
    var usedNames = new Set<String>();
    for (var rule in rules) {
      usedNames.add(rule.name);
    }

    for (var rule in rules) {
      if (!rule.isRecursive) {
        result.add(rule);
      } else {
        result.addAll(_remove(rule, usedNames));
      }
    }

    return result;
  }

  bool _canModifyExpression(Expression expression) {
    if (expression.action == null || expression.action.isEmpty) {
      return true;
    }

    return false;
  }

  bool _checkRecursion(List<Expression> expressions, int start, String ruleName) {
    var length = expressions.length;
    for (var i = start; i < length; i++) {
      var expression = expressions[i];
      if (expression is RuleExpression && expression.name == ruleName) {
        return true;
      }

      if (!expression.isOptional) {
        return false;
      }
    }

    return false;
  }

  bool _findRuleInExpression(Expression expression, String ruleName) {
    switch (expression.type) {
      case ExpressionTypes.AND_PREDICATE:
      case ExpressionTypes.NOT_PREDICATE:
      case ExpressionTypes.ONE_OR_MORE:
      case ExpressionTypes.OPTIONAL:
      case ExpressionTypes.ZERO_OR_MORE:
        UnaryExpression unaryExpression = expression;
        return _findRuleInExpression(unaryExpression.expression, ruleName);
      case ExpressionTypes.ANY_CHARACTER:
      case ExpressionTypes.CHARACTER_CLASS:
      case ExpressionTypes.LITERAL:
        return false;
      case ExpressionTypes.ORDERED_CHOICE:
      case ExpressionTypes.SEQUENCE:
        ListExpression listExpression = expression;
        for (var expression in listExpression.expressions) {
          if (_findRuleInExpression(expression, ruleName)) {
            return true;
          }
        }

        return false;
      case ExpressionTypes.RULE:
        RuleExpression ruleExpression = expression;
        return ruleExpression.name == ruleName;
      default:
        return false;
    }
  }

  OrderedChoiceExpression _generateReplacement(String ruleName, List<List<Expression>> expressions, List<RuleExpression> ruleExpressions, bool addEmpty) {
    var options = <SequenceExpression>[];
    for (var expression in expressions) {
      var list = <Expression>[];
      list.addAll(expression);
      var ruleExpression = new RuleExpression(ruleName);
      ruleExpressions.add(ruleExpression);
      list.add(ruleExpression);
      options.add(new SequenceExpression(list));
    }

    if (addEmpty) {
      var option = new SequenceExpression([new LiteralExpression("")]);
      options.add(option);
    }

    return new OrderedChoiceExpression(options);
  }

  ProductionRule _generateRule(ProductionRule parent, List<List<Expression>> expressions, Set<String> usedNames) {
    var name = _getName(parent.name, usedNames);
    var ruleExpressions = <RuleExpression>[];
    var choice = _generateReplacement(name, expressions, ruleExpressions, true);
    //choice = _wrap([choice], ExpressionTypes.OPTIONAL);
    var rule = new ProductionRule(name, choice);
    parent.allCallees.add(rule);
    parent.directCallees.add(rule);
    rule.allCallers.add(parent);
    rule.directCallers.add(parent);
    for (var ruleExpression in ruleExpressions) {
      ruleExpression.rule = rule;
    }

    // TODO:
    rule.isLexeme = parent.isLexeme;
    rule.isLexical = parent.isLexical;
    rule.isMorpheme = parent.isMorpheme;
    rule.isStartingRule = false;
    return rule;
  }

  String _getName(String name, Set<String> usedNames) {
    var result = name;
    var index = 1;
    while (true) {
      result = "$name$index";
      if (!usedNames.contains(result)) {
        usedNames.add(result);
        break;
      }
    }

    return result;
  }

  List<ProductionRule> _remove(ProductionRule rule, Set<String> usedNames) {
    var result = <ProductionRule>[];
    result.add(rule);
    var expression = rule.expression;
    var options = expression.expressions;
    var ruleName = rule.name;
    var alfas = <List<Expression>>[];
    var betas = <List<Expression>>[];
    for (var option in options) {
      var expressions = option.expressions;
      var isRecusrive = _checkRecursion(expressions, 0, ruleName);
      for (var expression in expressions) {
        if (isRecusrive) {
          // Check that the recursion is a first expression
          // Eg. A <- "a"? "b"* A
          if (!(expression is RuleExpression && expression.name == ruleName)) {
            return result;
          }

          // Not supported yet, A <- A
          if (expressions.length == 1) {
            return result;
          }

          var length2 = expressions.length;
          var numberOfOptionalExpressions = 0;
          for (var i = 0; i < length2; i++) {
            var expression = expressions[i];
            // Not allowed: Actions in the expressions when option starts with recursion.
            // Eg. A <- A a { $$ = $1; }
            var action = expression.action;
            if (action != null && !action.isEmpty) {
              return result;
            }

            if (i != 0) {
              // Not allowed: More than one of recursion in a single option
              // Eg. A <- A a A
              // TODO:
              if (_findRuleInExpression(expression, ruleName)) {
                return result;
              }

              if (expression.isOptional) {
                numberOfOptionalExpressions++;
              }
            }
          }

          // Not allowed: All alfas are an optional expressions
          // Eg. A <- A "a"? "b"*
          if (numberOfOptionalExpressions == length2 - 1) {
            return result;
          }

          alfas.add(expressions.sublist(1));
        } else {
          betas.add(expressions.toList());
        }

        break;
      }
    }

    if (alfas.length == 1 && betas.isEmpty) {
      // Input:
      // A <- A a
      // Output:
      // A <- a+
      //
      rule.expression = _wrap(alfas.first, ExpressionTypes.ONE_OR_MORE);
      return result;
    }

    if (alfas.length == 1 && betas.length == 1) {
      // Input:
      // A <- b / A b
      // Output:
      // A <- b+
      var length = alfas.length;
      if (betas.length == length) {
        var equal = true;
        var comparer = new _ExpressionComparer();
        var alfa = alfas.first;
        var beta = betas.first;
        var length = alfa.length;
        if (beta.length == length) {
          for (var i = 0; i < length; i++) {
            if (!comparer.compare(alfa[i], beta[i], true)) {
              equal = false;
              break;
            }
          }

          if (equal) {
            rule.expression = _wrap(alfas.first, ExpressionTypes.ONE_OR_MORE);
            return result;
          }
        }
      }
    }

    // Nothing to do
    if (alfas.length == 0 || betas.length == 0) {
      return result;
    }

    // Generate rule: A' <- a1 A' / aN A'
    var rule1 = _generateRule(rule, alfas, usedNames);
    result.add(rule1);
    rule.expression = _generateReplacement(rule1.name, betas, [], false);
    return result;
  }

  OrderedChoiceExpression _wrap(List<Expression> expressions, [ExpressionTypes type]) {
    SequenceExpression sequence;
    if (type != null) {
      Expression expression;
      if (expressions.length == 1) {
        expression = expressions.first;
      } else {
        expression = new SequenceExpression(expressions);
      }

      switch (type) {
        case ExpressionTypes.AND_PREDICATE:
          expression = new AndPredicateExpression(expression);
          break;
        case ExpressionTypes.NOT_PREDICATE:
          expression = new NotPredicateExpression(expression);
          break;
        case ExpressionTypes.ONE_OR_MORE:
          expression = new OneOrMoreExpression(expression);
          break;
        case ExpressionTypes.OPTIONAL:
          expression = new OptionalExpression(expression);
          break;
        case ExpressionTypes.ZERO_OR_MORE:
          expression = new ZeroOrMoreExpression(expression);
          break;
        default:
          throw new StateError("Unable to wrap into '$type'");
      }

      sequence = new SequenceExpression([expression]);
    } else {
      sequence = new SequenceExpression(expressions);
    }

    return new OrderedChoiceExpression([sequence]);
  }
}

class _ExpressionComparer {
  bool compare(Expression a, Expression b, bool compareActions) {
    if (a.type != b.type) {
      return false;
    }

    if (compareActions) {
      if (a.action != b.action) {
        return false;
      }
    }

    switch (a.type) {
      case ExpressionTypes.AND_PREDICATE:
      case ExpressionTypes.NOT_PREDICATE:
      case ExpressionTypes.ONE_OR_MORE:
      case ExpressionTypes.OPTIONAL:
      case ExpressionTypes.ZERO_OR_MORE:
        UnaryExpression a1 = a;
        UnaryExpression b1 = b;
        return compare(a1.expression, b1.expression, compareActions);
      case ExpressionTypes.ANY_CHARACTER:
        return true;
      case ExpressionTypes.CHARACTER_CLASS:
        CharacterClassExpression a1 = a;
        CharacterClassExpression b1 = b;
        var groups1 = a1.ranges.groups;
        var groups2 = b1.ranges.groups;
        var length = groups1.length;
        if (groups2.length != length) {
          return false;
        }

        for (var i = 0; i < length; i++) {
          if (groups1[i] != groups2[i]) {
            return false;
          }
        }

        return true;
      case ExpressionTypes.LITERAL:
        LiteralExpression a1 = a;
        LiteralExpression b1 = b;
        return a1.text == b1.text;
      case ExpressionTypes.ORDERED_CHOICE:
      case ExpressionTypes.SEQUENCE:
        ListExpression a1 = a;
        ListExpression b1 = b;
        var expressions1 = a1.expressions;
        var expressions2 = b1.expressions;
        var length = expressions1.length;
        if (expressions2.length == length) {
          return false;
        }

        for (var i = 0; i < length; i++) {
          if (!compare(expressions1[i], expressions2[i], compareActions)) {
            return false;
          }
        }

        return true;
      case ExpressionTypes.RULE:
        RuleExpression a1 = a;
        RuleExpression b1 = b;
        return a1.name == b1.name;
      default:
        throw new StateError("Unknown expression type: ${a.type}");
    }
  }
}
