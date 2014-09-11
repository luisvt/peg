part of peg.expression_generators;

class NotPredicateExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CH = GeneralParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GeneralParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENTS}}
var {{CH}} = $_CH, {{POS}} = $_CURSOR, {{TESTING}} = $_TESTING; 
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_CURSOR = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;''';

  NotPredicateExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! NotPredicateExpression) {
      throw new StateError('Expression must be NotPredicateExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var ch = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_CH);
    var pos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_POS);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_TESTING);
    block.assign('#EXPRESSION', _generators[0].generate());
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('TESTING', testing);
    return block.process();
  }
}
