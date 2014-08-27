part of peg.expression_generators;

class LiteralExpressionGenerator extends ExpressionGenerator {
  static const String _MATCH_STRING = MethodMatchStringGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_EMPTY = 'TEMPLATE_EMPTY';

  static final String _templateEmpty =
      '''
// {{#COMMENTS}}
$_SUCCESS = true;
$_RESULT = \'\';''';

  static final String _template =
      '''
{{#COMMENTS}}
$_RESULT = $_MATCH_STRING('{{LITERAL}}', {{EXPECTED}});''';

  LiteralExpression _expression;

  LiteralExpressionGenerator(Expression expression, ProductionRuleGenerator
      productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! LiteralExpression) {
      throw new StateError('Expression must be LiteralExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_EMPTY, _templateEmpty);
  }

  List<String> generate() {
    switch (_expression.text.length) {
      case 0:
        return _generateEmpty();
      default:
        return _generateNotEmpty();
    }
  }

  List<String> _generateEmpty() {
    var block = getTemplateBlock(_TEMPLATE_EMPTY);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    return block.process();
  }

  List<String> _generateNotEmpty() {
    var block = getTemplateBlock(_TEMPLATE);
    var literal = [];
    var text = _expression.text;
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    for (var charCode in text.codeUnits) {
      literal.add(Utils.charToString(charCode));
    }

    block.assign('EXPECTED', ExpressionGenerator.getExpectedOnFailure(
        _expression));
    block.assign('LITERAL', literal.join());
    return block.process();
  }
}
