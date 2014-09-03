part of peg.expressions;

class ExpressionTypes {
  static const ExpressionTypes AND_PREDICATE = const ExpressionTypes('AND_PREDICATE');

  static const ExpressionTypes ANY_CHARACTER = const ExpressionTypes('ANY_CHARACTER');

  static const ExpressionTypes CHARACTER_CLASS = const ExpressionTypes('CHARACTER_CLASS');

  static const ExpressionTypes LITERAL = const ExpressionTypes('LITERAL');

  static const ExpressionTypes NOT_PREDICATE = const ExpressionTypes('NOT_PREDICATE');

  static const ExpressionTypes ONE_OR_MORE = const ExpressionTypes('ONE_OR_MORE');

  static const ExpressionTypes OPTIONAL = const ExpressionTypes('OPTIONAL');

  static const ExpressionTypes ORDERED_CHOICE = const ExpressionTypes('ORDERED_CHOICE');

  static const ExpressionTypes RULE = const ExpressionTypes('RULE');

  static const ExpressionTypes SEQUENCE = const ExpressionTypes('SEQUENCE');

  static const ExpressionTypes ZERO_OR_MORE = const ExpressionTypes('ZERO_OR_MORE');

  final String name;

  const ExpressionTypes(this.name);

  String toString() {
    return name;
  }
}
