part of peg.frontend_analyzer;

class TerminalRulesFinder {
  find(List<ProductionRule> rules) {
    _reanalyze(rules);
    for (var rule in rules) {
      var expression = rule.expression;
      if (expression.startsWithAny) {
        rule.isMasterTerminal = false;
        rule.isSlaveTerminal = false;
        rule.isTerminal = false;
      }
    }

    _reanalyze(rules);
  }

  void _reanalyze(List<ProductionRule> rules) {
    for (var rule in rules) {
      rule.isTerminal = isTerminal(rule);
    }

    for (var rule in rules) {
      rule.isMasterTerminal = isMasterTerminal(rule);
    }

    for (var rule in rules) {
      rule.isSlaveTerminal = isSlaveTerminal(rule);
    }
  }

  bool isMasterTerminal(ProductionRule rule) {
    if (!isTerminal(rule)) {
      return false;
    }

    for (var caller in rule.directCallers) {
      if (!isTerminal(caller)) {
        return true;
      }
    }

    return false;
  }

  bool isSlaveTerminal(ProductionRule rule) {
    if (!isTerminal(rule)) {
      return false;
    }

    for (var caller in rule.directCallers) {
      if (isTerminal(caller)) {
        return true;
      }
    }

    return false;
  }

  bool isTerminal(ProductionRule rule) {
    if (rule.isTerminal == false) {
      return false;
    }

    if (rule.isUsed) {
      // TODO:
      if (!rule.isRecursive) {
        for (var callee in rule.allCallees) {
          if (!isTerminal(callee)) {
            return false;
          }
        }

        return true;
      } else if (rule.allCallees.length == 1) {
        return true;
      }
    }

    return false;
  }
}
