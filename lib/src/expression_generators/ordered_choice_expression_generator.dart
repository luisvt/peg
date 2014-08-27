part of peg.expression_generators;

class OrderedChoiceExpressionGenerator extends ListExpressionGenerator {
  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE_INNER = 'TEMPLATE_INNER';

  static const String _TEMPLATE_LAST = 'TEMPLATE_LAST';

  static const String _TEMPLATE_OUTER = 'TEMPLATE_OUTER';

  static const String _TEMPLATE_SINGLE = 'TEMPLATE_SINGLE';

  static final String _templateInner =
      '''
{{#EXPRESSION}}
if ($_SUCCESS) break;''';

  static final String _templateOuter =
      '''
{{#COMMENTS}}
while (true) {
  {{#EXPRESSIONS}}
  break;
}''';

  static final String _templateLast = '''
{{#EXPRESSION}}''';

  static final String _templateSingle = '''
{{#EXPRESSION}}''';

  OrderedChoiceExpression _expression;

  OrderedChoiceExpressionGenerator(Expression expression, ProductionRuleGenerator
      productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! OrderedChoiceExpression) {
      throw new StateError('Expression must be OrderedChoiceExpression');
    }

    addTemplate(_TEMPLATE_INNER, _templateInner);
    addTemplate(_TEMPLATE_LAST, _templateLast);
    addTemplate(_TEMPLATE_OUTER, _templateOuter);
    addTemplate(_TEMPLATE_SINGLE, _templateSingle);
  }

  List<String> generate() {
    switch (_expression.expressions.length) {
      case 0:
        throw new StateError('The expressions list has zero length');
      case 1:
        return _generateSingle();
      default:
        return _generateSeveral();
    }
  }

  List<String> _generateSeveral() {
    var block = getTemplateBlock(_TEMPLATE_OUTER);
    var length = _expression.expressions.length;
    for (var i = 0; i < length; i++) {
      TemplateBlock inner;
      var generator = _generators[i];
      if (i != length - 1) {
        inner = getTemplateBlock(_TEMPLATE_INNER);
      } else {
        inner = getTemplateBlock(_TEMPLATE_LAST);
      }

      inner.assign('#EXPRESSION', generator.generate());
      block.assign('#EXPRESSIONS', inner.process());
    }

    return block.process();
  }

  List<String> _generateSingle() {
    var block = getTemplateBlock(_TEMPLATE_SINGLE);
    block.assign('#EXPRESSION', _generators[0].generate());
    return block.process();
  }
}
