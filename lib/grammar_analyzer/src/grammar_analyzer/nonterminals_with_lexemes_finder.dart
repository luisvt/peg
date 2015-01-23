part of peg.grammar_analyzer.grammar_analyzer;

class NonterminalsWithLexemesFinder extends UnifyingExpressionVisitor {
  Map<ProductionRule, List<Expression>> result;

  Map<ProductionRule, List<Expression>> find(List<ProductionRule> rules) {
    result = new Map<ProductionRule, List<Expression>>();
    for (var rule in rules) {
      if (rule.isSentence) {
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
    var groups = expression.ranges.groups;
    var skip = false;
    if (groups.length == 1) {
      var first = groups.first;
      if (first.start == first.end) {
        skip = true;
      }
    }

    if (!skip) {
      _addExpression(expression);
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.text.isEmpty) {
      _addExpression(expression);
    }

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
