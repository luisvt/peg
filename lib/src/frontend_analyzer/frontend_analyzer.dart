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

    new ExpectedLexemesResolver().resolve(rules);
    new TerminalRulesFinder().find(rules);

    // Exprerimental
    // var automaton = new AutomatonResolver();
    // automaton.resolve(rules);
    //_print(automaton.state0, new Set<ExpressionState>());
  }

  void _print(ExpressionState state, Set<ExpressionState> reported) {
    if (reported.contains(state)) {
      return;
    }

    reported.add(state);
    var transitions = state.transitions;
    print("==============");
    print("${state.owner}:");
    for (var index in transitions.getIndexes()) {
      var s = toPrintable(new String.fromCharCode(index));
      var states = transitions[index];
      print("$s ($index): ${states.elements}");
      for (var state in states.elements) {
        _print(state, reported);
      }
    }
  }
}
