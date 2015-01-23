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
    new ProductionRulesKindsResolver().find(grammar);
    // TODO: Optimize NotPredicate in ExpectedLexemesResolver
    new ExpectedLexemesResolver().resolve(rules);
    new ExpressionWithActionsResolver().resolve(startingRules);


    /*
    // Exprerimental
    for (var rule in rules) {
      if (rule.directCallers.length == 0) {
        var builder = new AutomatonBuilder();
        builder.build(rule);
      }
    }
    */
  }
}
