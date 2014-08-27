part of peg.grammar_analyzer;

// TODO: remove
class NonterminalsWithLexemesFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<Expression>> result;

  Map<ProductionRule, List<Expression>> find(List<ProductionRule> rules) {
    result = new Map<ProductionRule, List<Expression>>();
    for (var rule in rules) {
      if (!rule.isTerminal) {
        rule.expression.accept(this);
      }
    }

    return result;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    _addExpression(expression);
    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    _addExpression(expression);
    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    _addExpression(expression);
    return null;
  }

  void _addExpression(Expression expression) {
    var list = result[expression.owner];
    if (list == null) {
      list = new List<Expression>();
      result[expression.owner] = list;
    }

    list.add(expression);
  }
}
