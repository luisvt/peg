part of peg.frontend_analyzer.frontend_analyzer;

class TerminalRulesFinder {
  find(List<ProductionRule> rules) {
    _reanalyze(rules);
    for (var rule in rules) {
      var expression = rule.expression;
    }

    _reanalyze(rules);
    var id = 0;
    for (var rule in rules) {
      if (rule.isLexical) {
        rule.tokenId = id++;
      }
    }
  }

  void _reanalyze(List<ProductionRule> rules) {
    for (var rule in rules) {
      rule.isLexical = isTerminal(rule);
    }

    for (var rule in rules) {
      rule.isLexeme = isLexeme(rule);
    }

    for (var rule in rules) {
      rule.isMorpheme = isMorpheme(rule);
    }
  }

  bool isLexeme(ProductionRule rule) {
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

  bool isMorpheme(ProductionRule rule) {
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
    if (rule.isLexical == false) {
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
