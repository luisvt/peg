part of peg.general_parser.expressions_generators;

class NotPredicateExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENT_IN}}
var {{CH}} = $_CH, {{POS}} = $_CURSOR, {{TESTING}} = $_TESTING; 
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_CURSOR = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;
{{#COMMENT_OUT}}''';

  NotPredicateExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! NotPredicateExpression) {
      throw new StateError('Expression must be NotPredicateExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var ch = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.CH);
    var pos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.POS);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.TESTING);
    block.assign('#EXPRESSION', _generators[0].generate());
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('TESTING', testing);
    return block.process();
  }
}
