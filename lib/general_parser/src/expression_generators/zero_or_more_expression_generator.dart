part of peg.general_parser.expressions_generators;

class ZeroOrMoreExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = '_TEMPLATE';

  static final String _template = '''
{{#COMMENTS}}
var {{TESTING}} = $_TESTING; 
for (var reps = []; ; ) {
  $_TESTING = $_CURSOR;
  {{#EXPRESSION}}
  if ($_SUCCESS) {  
    reps.add($_RESULT);
  } else {
    $_SUCCESS = true;
    $_TESTING = {{TESTING}};
    $_RESULT = reps;
    break; 
  }
}''';

  ZeroOrMoreExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! ZeroOrMoreExpression) {
      throw new StateError('Expression must be ZeroOrMoreExpression');
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var testing = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.TESTING);
    block.assign('#EXPRESSION', _generators[0].generate());
    if (options.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('TESTING', testing);
    return block.process();
  }
}
