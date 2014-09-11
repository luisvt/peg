part of peg.expression_generators;

class OptionalExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GeneralParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENTS}}
var {{TESTING}} = $_TESTING;
$_TESTING = $_CURSOR;
{{#EXPRESSION}}
$_SUCCESS = true; 
$_TESTING = {{TESTING}};''';

  OptionalExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! OptionalExpression) {
      throw new StateError('Expression must be OptionalExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_TESTING);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('TESTING', testing);
    block.assign('#EXPRESSION', _generators[0].generate());
    return block.process();
  }
}
