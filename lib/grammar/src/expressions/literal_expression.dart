part of peg.grammar.expressions;

class LiteralExpression extends Expression {
  final String text;

  final String quote;

  LiteralExpression(this.text, [this.quote = '\'']) : super() {
    if (text == null) {
      throw new ArgumentError('text: $text');
    }

    if (quote != '"' && quote != '\'') {
      throw new ArgumentError('quote: $quote');
    }
  }

  int get maxTimes => 1;

  int get minTimes => 1;

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
    var quoteChar = quote.codeUnitAt(0);
    List<String> strings = [];
    for (var charCode in text.codeUnits) {
      strings.add(_escape(charCode, quoteChar));
    }

    return '$quote${strings.join()}$quote';
  }

  String _escape(int character, int quote) {
    switch (character) {
      case 9:
        return '\\t';
      case 10:
        return '\\n';
      case 13:
        return '\\r';
    }

    if (character < 32 || character >= 127) {
      return "\\u${character.toRadixString(16)}";
    }

    switch (character) {
      case 92:
        return '\\\\';
    }

    if (character == quote) {
      return '\\${new String.fromCharCode(character)}';
    }

    return new String.fromCharCode(character);
  }
}
