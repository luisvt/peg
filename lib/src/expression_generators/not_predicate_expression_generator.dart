part of peg.expression_generators;

class NotPredicateExpressionGenerator extends UnaryExpressionGenerator {
  static const String _CH = ParserClassGenerator.VARIABLE_CH;

  static const String _CURSOR = ParserClassGenerator.VARIABLE_CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = ParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_PROLOG = 'TEMPLATE_PROLOG';

  static const String _TEMPLATE_PROLOG_BREAK = 'TEMPLATE_PROLOG_BREAK';

  static final String _template = '''
{{#COMMENTS}}
var {{CH}} = $_CH, {{POS}} = $_CURSOR, {{TESTING}} = $_TESTING; 
$_TESTING = $_INPUT_LEN + 1;
{{#EXPRESSION}}
$_CH = {{CH}};
$_CURSOR = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;
{{#PROLOG}}''';

  static final String _templateProlog = '''
if (!$_SUCCESS && $_CURSOR > $_TESTING) $_FAILURE();''';

  static final String _templatePrologBreak = '''
if (!$_SUCCESS) {
  if ($_CURSOR > $_TESTING) $_FAILURE();
  break;
}''';

  bool _breakOnFailInserted;

  NotPredicateExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! NotPredicateExpression) {
      throw new StateError('Expression must be NotPredicateExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_PROLOG, _templateProlog);
    addTemplate(_TEMPLATE_PROLOG_BREAK, _templatePrologBreak);
    _breakOnFailInserted = false;
  }

  bool breakOnFailWasInserted() {
    return _breakOnFailInserted;
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

    if (canInserBreakOnFail()) {
      _breakOnFailInserted = true;
      var prolog = getTemplateBlock(_TEMPLATE_PROLOG_BREAK);
      block.assign('#PROLOG', prolog.process());
    } else {
      var prolog = getTemplateBlock(_TEMPLATE_PROLOG);
      block.assign('#PROLOG', prolog.process());
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('TESTING', testing);
    return block.process();
  }
}
