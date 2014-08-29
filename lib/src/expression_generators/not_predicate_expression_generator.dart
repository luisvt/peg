part of peg.expression_generators;

class NotPredicateExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GrammarGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template_OLD = '''
{{#COMMENTS}}
var {{CH}} = $_CH;
var {{POS}} = $_INPUT_POS;
var {{TESTING}} = $_TESTING; 
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_INPUT_POS = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;
if (!$_SUCCESS && $_INPUT_POS > $_TESTING) $_FAILURE();''';

  static final String _template = '''
{{#COMMENTS}}
var {{CH}} = $_CH;
var {{POS}} = $_INPUT_POS;
var {{TESTING}} = $_TESTING; 
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_INPUT_POS = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;
if (!$_SUCCESS) {
  if ($_INPUT_POS > $_TESTING) $_FAILURE();
  {{#BREAK}}
}''';

  bool _breakOnFailInserted;

  NotPredicateExpressionGenerator(Expression expression,
      ProductionRuleGenerator productionRuleGenerator) : super(
      expression,
      productionRuleGenerator) {
    if (expression is! NotPredicateExpression) {
      throw new StateError('Expression must be NotPredicateExpression');
    }

    addTemplate(_TEMPLATE, _template);
    _breakOnFailInserted = false;
  }

  bool breakOnFailWasInserted() {
    return _breakOnFailInserted;
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var ch =
        productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_CH);
    var pos =
        productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_POS);
    var testing =
        productionRuleGenerator.allocateBlockVariable(
            ExpressionGenerator.VARIABLE_TESTING);
    block.assign('#EXPRESSION', _generators[0].generate());
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('TESTING', testing);
    return block.process();
  }
}
