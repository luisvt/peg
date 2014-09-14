part of peg.frontend_analyzer;

class FrontendAnalyzer {
  void analyze(Grammar grammar) {
    var rules = grammar.rules;
    new RuleExpressionsResolver().resolve(grammar.rulesMap);
    // TODO: remove
    var levels = new ExpressionLevelResolver().resolve(rules);
    for (var rule in rules) {
      rule.expression.accept(new ExpressionHierarchyResovler());
    }

    for (var rule in rules) {
      rule.expression.accept(new ExpressionOwnershipResolver());
    }

    new OptionalExpressionsResolver().resolve(rules);
    new RepetitionExpressionsResolver().resolve(rules);
    new ExpressionAbleNotConsumeInputResolver().resolve(rules);
    new LeftExpressionsResolver().resolve(rules);
    new RightExpressionsResolver().resolve(rules);
    new StartCharactersResolver().resolve(rules);
    for (var i = 0; i <= 1; i++) {
      for (var rule in rules) {
        rule.expression.accept(new InvocationsResolver(i == 0));
      }
    }

    new TerminalRulesFinder().find(rules);
    new ExpectedTerminalsResolver().resolve(rules);
    new ExpressionWithActionsResolver().resolve(rules);
    new StartingRulesFinder().find(rules);

    // Exprerimental
    for (var rule in rules) {
      if (rule.directCallers.length == 0) {
        //var resolver = new AutomatonResolver();
        //resolver.resolve([rule]);
        //_print(resolver.state0, new Set<ExpressionState>());
        //print("==============");
      }
    }
  }

  void _print(ExpressionState state, Set<ExpressionState> reported) {
    if (reported.contains(state)) {
      return;
    }

    reported.add(state);
    var transitions = state.symbolTransitions;
    print("==============");
    print("State: $state:");
    for (var group in transitions.groups) {
      var start = toPrintable(new String.fromCharCode(group.start));
      var end = toPrintable(new String.fromCharCode(group.end));
      print("  [$start-$end] => ${group.key}");
      for (var state in group.key.elements) {
        _print(state, reported);
      }
    }
  }
}
