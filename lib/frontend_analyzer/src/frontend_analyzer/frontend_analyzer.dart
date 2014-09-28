part of peg.frontend_analyzer.frontend_analyzer;

class FrontendAnalyzer {
  void analyze(Grammar grammar) {
    var rules = grammar.productionRules;
    new RuleExpressionsResolver().resolve(grammar.rulesMap);
    // TODO: remove
    var levels = new ExpressionLevelResolver().resolve(rules);
    for (var rule in rules) {
      rule.expression.accept(new ExpressionHierarchyResovler());
    }

    for (var rule in rules) {
      rule.expression.accept(new ExpressionOwnershipResolver());
    }

    for (var i = 0; i <= 1; i++) {
      for (var rule in rules) {
        rule.expression.accept(new InvocationsResolver(i == 0));
      }
    }

    var startingRules = new StartingRulesFinder().find(rules);

    new OptionalExpressionsResolver().resolve(startingRules);
    new RepetitionExpressionsResolver().resolve(startingRules);
    new ExpressionAbleNotConsumeInputResolver().resolve(startingRules);
    new LeftExpressionsResolver().resolve(startingRules);
    new RightExpressionsResolver().resolve(startingRules);
    new ExpressionLengthResovler().resolve(startingRules);
    new StartCharactersResolver().resolve(startingRules);
    new ExpressionMatchesEofResolver().resolve(startingRules);

    // TODO: Use startingRules
    new TerminalRulesFinder().find(rules);
    // TODO: Optimize NotPredicate in ExpectedLexemesResolver
    new ExpectedLexemesResolver().resolve(rules);
    new ExpressionWithActionsResolver().resolve(startingRules);

    /*
    // Exprerimental
    for (var rule in rules) {
      if (rule.directCallers.length == 0) {
        //var resolver = new AutomatonResolver();
        //resolver.resolve([rule]);
        //_print(resolver.state0, new Set<ExpressionState>());
        //print("==============");
      }
    }
    */
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
