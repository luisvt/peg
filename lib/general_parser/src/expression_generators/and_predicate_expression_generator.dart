part of peg.general_parser.expressions_generators;

class AndPredicateExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENTS}}
var {{CH}} = $_CH, {{POS}} = $_CURSOR, {{TESTING}} = $_TESTING;
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_CURSOR = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;''';

  AndPredicateExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! AndPredicateExpression) {
      throw new StateError('Expression must be AndPredicateExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  // TODO: Not tested
  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var ch = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.CH);
    var pos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.POS);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.TESTING);
    if (options.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('TESTING', testing);
    block.assign('#EXPRESSION', _generators[0].generate());
    return block.process();
  }
}
