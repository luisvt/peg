part of peg.expression_generators;

class AnyCharacterExpressionGenerator extends ExpressionGenerator {
  static const String _MATCH_ANY = MethodMatchAnyGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template =
      '''
{{#COMMENTS}}
$_RESULT = $_MATCH_ANY();''';

  AnyCharacterExpressionGenerator(Expression expression, ProductionRuleGenerator
      productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! AnyCharacterExpression) {
      throw new StateError('Expression must be AnyCharacterExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    return block.process();
  }
}
