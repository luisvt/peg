part of peg.general_parser.expressions_generators;

abstract class ExpressionGenerator extends TemplateGenerator {
  static const String CH = "ch";

  static const String POS = "pos";

  static const String TESTING = "testing";

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  final ProductionRuleGenerator productionRuleGenerator;

  Expression _expression;

  List<ExpressionGenerator> _generators = [];

  ParserGeneratorOptions _options;

  GeneralParserGenerator _parserGenerator;

  GeneralParserClassGenerator _parserClassGenerator;

  ExpressionGenerator(Expression expression, this.productionRuleGenerator) {
    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    if (productionRuleGenerator == null) {
      throw new ArgumentError('productionRuleGenerator: $productionRuleGenerator');
    }

    _parserClassGenerator = productionRuleGenerator.parserClassGenerator;
    _parserGenerator = _parserClassGenerator.parserGenerator;
    _options = _parserGenerator.options;
    _expression = expression;
  }

  ParserGeneratorOptions get options => _options;

  GeneralParserGenerator get parsertGenerator => _parserGenerator;

  GeneralParserClassGenerator get parserClassGenerator => _parserClassGenerator;

  ExpressionGenerator createGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) {
    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    switch (expression.type) {
      case ExpressionTypes.AND_PREDICATE:
        return new AndPredicateExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.ANY_CHARACTER:
        return new AnyCharacterExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.CHARACTER_CLASS:
        return new CharacterClassExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.LITERAL:
        return new LiteralExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.NOT_PREDICATE:
        return new NotPredicateExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.ONE_OR_MORE:
        return new OneOrMoreExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.OPTIONAL:
        return new OptionalExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.ORDERED_CHOICE:
        return new OrderedChoiceExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.RULE:
        return new RuleExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.SEQUENCE:
        return new SequenceExpressionGenerator(expression, productionRuleGenerator);
      case ExpressionTypes.ZERO_OR_MORE:
        return new ZeroOrMoreExpressionGenerator(expression, productionRuleGenerator);
      default:
        throw new StateError('Unknown expression type: ${expression.type}');
    }
  }

  bool breakOnFailWasInserted() {
    return false;
  }

  // TODO: Not a good place here, implementation should be in parent
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

    return false;
  }
}
