part of peg.frontend_analyzer.frontend_analyzer;

class ProductionRulesKindsResolver {
  List<_RuleKindChangeRecord> _changeRecords;

  find(Grammar grammar) {
    var rules = grammar.productionRules;
    _changeRecords = <_RuleKindChangeRecord>[];
    for (var rule in rules) {
      rule.kind = ProductionRuleKinds.MORHEME;
      rule.tokenId = null;
    }

    while (_analyze(rules));
    var id = 0;
    for (var rule in rules) {
      if (rule.isLexeme) {
        rule.tokenId = id++;
      }
    }

    var logs = _logChanges();
    grammar.logs.addAll(logs);
  }

  bool _analyze(List<ProductionRule> rules) {
    var hasChanges = false;
    for (var rule in rules) {
      var calleeLexeme = 0;
      var calleeMorpheme = 0;
      var calleeSentence = 0;
      var callerLexeme = 0;
      var callerMorpheme = 0;
      var callerSentence = 0;
      var kind = rule.kind;
      for (var callee in rule.directCallees) {
        if (callee == rule) {
          continue;
        }

        if (callee.kind == ProductionRuleKinds.LEXEME) {
          calleeLexeme++;
        }

        if (callee.kind == ProductionRuleKinds.MORHEME) {
          calleeMorpheme++;
        }

        if (callee.kind == ProductionRuleKinds.SENTENCE) {
          calleeSentence++;
        }
      }

      for (var caller in rule.directCallers) {
        if (caller == rule) {
          continue;
        }

        if (caller.kind == ProductionRuleKinds.LEXEME) {
          callerLexeme++;
        }

        if (caller.kind == ProductionRuleKinds.MORHEME) {
          callerMorpheme++;
        }

        if (caller.kind == ProductionRuleKinds.SENTENCE) {
          callerSentence++;
        }
      }

      var calleeAll = calleeLexeme + calleeMorpheme + calleeSentence;
      var callerAll = callerLexeme + callerMorpheme + callerSentence;
      if (callerAll == 0) {
        var reason = "callerAll == 0";
        hasChanges = _markAsSentence(rule, hasChanges, reason: reason);
      }

      if (callerSentence > 0) {
        if (kind == ProductionRuleKinds.MORHEME) {
          var list = <String>[];
          for (var caller in rule.directCallers) {
            if (caller.isSentence) {
              list.add(caller.name);
            }
          }

          var reason = "callerSentence > 0 (${list.join(", ")})";
          hasChanges = _markAsLexeme(rule, hasChanges, reason: reason);
        }
      }

      if (calleeLexeme > 0) {
        switch (kind) {
          case ProductionRuleKinds.MORHEME:
          case ProductionRuleKinds.LEXEME:
            var list = <String>[];
            for (var callee in rule.directCallees) {
              if (callee.isLexeme) {
                list.add(callee.name);
              }
            }

            var reason = "calleeLexeme > 0 (${list.join(", ")})";
            hasChanges = _markAsSentence(rule, hasChanges, reason: reason);
            break;
        }
      }

      if (calleeSentence > 0) {
        switch (kind) {
          case ProductionRuleKinds.MORHEME:
          case ProductionRuleKinds.LEXEME:
            var list = <String>[];
            for (var callee in rule.directCallees) {
              if (callee.isSentence) {
                list.add(callee.name);
              }
            }

            var reason = "calleeSentence > 0 (${list.join(", ")})";
            hasChanges = _markAsSentence(rule, hasChanges, reason: reason);
            break;
        }
      }

      if (rule.isRecursive && rule.kind == ProductionRuleKinds.MORHEME) {
        var list = <String>[];
        for (var callee in rule.directCallees) {
          if (callee == rule) {
            continue;
          }

          if (callee.allCallees.contains(rule)) {
            list.add(callee.name);
          }
        }

        if (!list.isEmpty) {
          var reason = "isRecursive && MORPHEME (${list.join(", ")})";
          hasChanges = _markAsLexeme(rule, hasChanges, reason: reason);
        }
      }
    }

    return hasChanges;
  }

  List<String> _logChanges() {
    var result = <String>[];
    var maxNameLength = 0;
    for (var record in _changeRecords) {
      var length = record.rule.name.length;
      if (maxNameLength < length) {
        maxNameLength = length;
      }
    }

    var maxKindLength = "SENTENCE".length;
    for (var record in _changeRecords) {
      var buffer = new StringBuffer();
      var name = record.rule.name;
      name = name.padRight(maxNameLength, " ");
      buffer.write(name);
      buffer.write(" ");
      var kind = record.newKind.toString();
      kind = kind.padRight(maxKindLength, " ");
      buffer.write(kind);
      buffer.write(" <= ");
      kind = record.oldKind.toString();
      kind = kind.padRight(maxKindLength, " ");
      buffer.write(kind);
      buffer.write(": ");
      var reason = record.reason;
      if (reason != null) {
        buffer.write(reason);
      }

      result.add(buffer.toString());
    }

    return result;
  }

  bool _markAsLexeme(ProductionRule rule, bool hasChanges, {String reason}) {
    assert(rule.kind != ProductionRuleKinds.SENTENCE);
    return _setKind(rule, ProductionRuleKinds.LEXEME, hasChanges, reason: reason);
  }

  bool _markAsMorpheme(ProductionRule rule, bool hasChanges, {String reason}) {
    assert(rule.kind != ProductionRuleKinds.LEXEME);
    assert(rule.kind != ProductionRuleKinds.SENTENCE);
    return _setKind(rule, ProductionRuleKinds.MORHEME, hasChanges, reason: reason);
  }

  bool _markAsSentence(ProductionRule rule, bool hasChanges, {String reason}) {
    return _setKind(rule, ProductionRuleKinds.SENTENCE, hasChanges, reason: reason);
  }

  bool _setKind(ProductionRule rule, ProductionRuleKinds kind, bool hasChanges, {String reason}) {
    if (rule.kind == kind) {
      return hasChanges;
    }

    var prev = rule.kind;
    rule.kind = kind;
    _changeRecords.add(new _RuleKindChangeRecord(newKind: kind, oldKind: prev, reason: reason, rule: rule));
    return true;
  }
}

class _RuleKindChangeRecord {
  final ProductionRuleKinds newKind;

  final ProductionRuleKinds oldKind;

  final ProductionRule rule;

  final String reason;

  _RuleKindChangeRecord({this.newKind, this.oldKind, this.reason, this.rule});
}
