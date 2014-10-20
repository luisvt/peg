part of peg.grammar.grammar_analyzer;

class LanguageHidingFinder extends UnifyingExpressionVisitor {
  Set<Expression> processed;

  Object visitLiteral(LiteralExpression expression) {
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    var expressions = expression.expressions;
    var length = expressions.length;
    for (var i = 0; i < length - 1; i++) {
      var prev = expressions[i];
      for (var j = i + 1; j < length; j++) {
        var next = expressions[j];
        //
      }
    }

    return null;
  }


}
