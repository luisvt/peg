part of peg.expressions;

class LiteralExpression extends Expression {
  final String text;

  final String quote;

  String _definition;

  LiteralExpression(this.text, [this.quote = '"']) : super() {
    if (text == null) {
      throw new ArgumentError('text: $text');
    }

    if (quote != '"' && quote != '\'') {
      throw new ArgumentError('quote: $quote');
    }
  }

  ExpressionTypes get type {
    return ExpressionTypes.LITERAL;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitLiteral(this);
  }

  Object visitChildren(ExpressionVisitor visitor) {
    return this;
  }

  String toString() {
    if (_definition == null) {
      List<String> strings = [];
      for (var charCode in text.codeUnits) {
        strings.add(Utils.charToString(charCode));
      }

      _definition = '$quote${strings.join()}$quote';
    }

    return '$quote${escape(text)}$quote';
    // return _definition;
  }
}
