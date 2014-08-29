part of peg.expression_generators;

abstract class ExpressionGenerator extends TemplateGenerator {
  static const String VARIABLE_CH = "ch";

  static const String VARIABLE_POS = "pos";

  static const String VARIABLE_SKIP = "skip";

  static const String VARIABLE_TESTING = "testing";

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  final ProductionRuleGenerator productionRuleGenerator;

  Expression _expression;

  List<ExpressionGenerator> _generators = [];

  ExpressionGenerator(Expression expression, this.productionRuleGenerator) {
    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    if (productionRuleGenerator == null) {
      throw new ArgumentError(
          'productionRuleGenerator: $productionRuleGenerator');
    }

    _expression = expression;
  }

  ExpressionGenerator createGenerator(Expression expression,
      ProductionRuleGenerator productionRuleGenerator) {
    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    switch (expression.type) {
      case ExpressionTypes.AND_PREDICATE:
        return new AndPredicateExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.ANY_CHARACTER:
        return new AnyCharacterExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.CHARACTER_CLASS:
        return new CharacterClassExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.LITERAL:
        return new LiteralExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.NOT_PREDICATE:
        return new NotPredicateExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.ONE_OR_MORE:
        return new OneOrMoreExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.OPTIONAL:
        return new OptionalExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.ORDERED_CHOICE:
        return new OrderedChoiceExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.RULE:
        return new RuleExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.SEQUENCE:
        return new SequenceExpressionGenerator(
            expression,
            productionRuleGenerator);
      case ExpressionTypes.ZERO_OR_MORE:
        return new ZeroOrMoreExpressionGenerator(
            expression,
            productionRuleGenerator);
      default:
        throw new StateError('Unknown expression type: ${expression.type}');
    }
  }

  // TODO: Use this widely for improve "expectation"
  static String getExpectedOnFailure(Expression expression) {
    var result = [];
    var lexemes = expression.expectedLexemes;
    if (!lexemes.contains(null)) {
      for (var lexeme in lexemes) {
        result.add("\"${toPrintableString(lexeme)}\"");
      }
    }

    if (result.isEmpty) {
      if (expression is OrderedChoiceExpression && expression.parent == null) {
        var owner = expression.owner;
        if (expression.owner.isTerminal) {
          result.add("\"${owner.name}\"");
        }
      }
    }

    if (result.length > 0) {
      return "const [${result.join(", ")}]";
    }

    return "null";
  }

  static String toPrintableString(String string) {
    if (string == null) {
      return "null";
    }

    if (string.isEmpty) {
      return "";
    }

    return Utils.toPrintable(string);
  }

  bool breakOnFailWasInserted() {
    return false;
  }

  bool canInserBreakOnFail() {
    var parent = _expression.parent;
    if (parent == null) {
      return false;
    }

    if (parent is SequenceExpression) {
      var expressions = parent.expressions;
      var length = expressions.length;
      if (length == 1) {
        return false;
      }

      return true;
    }

    if (parent is OrderedChoiceExpression) {
      var expressions = parent.expressions;
      var length = expressions.length;
      if (length == 1) {
        return false;
      }

      return _expression != expressions.last;
    }

    return false;
  }
}
