part of peg.general_parser.expressions_generators;

class OptionalExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
{{#COMMENT_IN}}
var {{TESTING}} = $_TESTING;
$_TESTING = $_CURSOR;
{{#EXPRESSION}}
$_SUCCESS = true; 
$_TESTING = {{TESTING}};
{{#COMMENT_OUT}}''';

  OptionalExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! OptionalExpression) {
      throw new StateError('Expression must be OptionalExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.TESTING);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('TESTING', testing);
    block.assign('#EXPRESSION', _generators[0].generate());
    return block.process();
  }
}
