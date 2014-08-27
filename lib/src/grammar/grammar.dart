part of peg.grammar;

class Grammar {
  final String globals;

  final String members;

  Map<String, ProductionRule> _map;

  List<ProductionRule> _rules;

  Grammar(List<ProductionRule> rules, [this.globals, this.members]) {
    if (rules == null) {
      throw new ArgumentError('rules: $rules');
    }

    var map = new Map<String, ProductionRule>();
    var id = 0;
    for (var rule in rules) {
      if (rule == null || rule is! ProductionRule) {
        throw new StateError('The rules list contains illegal rule');
      }

      rule.id = id++;
      map[rule.name] = rule;
    }

    _rules = rules;
    _map = map;
    var resolver = new _RuleExpressionResolver();
    resolver.resolve(_map);
    new FrontendAnalyzer().analyze(this);
  }

  List<ProductionRule> get rules {
    return _rules;
  }

  Map<String, ProductionRule> get rulesMap {
    return _map;
  }

  String toString() {
    var strings = [];
    for (var rule in rules) {
      strings.add('$rule');
    }

    return strings.join('\n\n');
  }
}
