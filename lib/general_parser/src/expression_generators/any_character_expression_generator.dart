part of peg.general_parser.expressions_generators;

class AnyCharacterExpressionGenerator extends ExpressionGenerator {
  static const String _MATCH_ANY = MethodMatchAnyGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_ANY();
{{#COMMENT_OUT}}''';

  AnyCharacterExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! AnyCharacterExpression) {
      throw new StateError('Expression must be AnyCharacterExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    return block.process();
  }
}
