part of peg.expression_generators;

class LiteralExpressionGenerator extends ExpressionGenerator {
  static const String _MATCH_CHAR = MethodMatchCharGenerator.NAME;

  static const String _MATCH_STRING = MethodMatchStringGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE_CHARACTER = 'TEMPLATE_CHARACTER';

  static const String _TEMPLATE_EMPTY = 'TEMPLATE_EMPTY';

  static const String _TEMPLATE_STRING = 'TEMPLATE_STRING';

  static final String _templateEmpty = '''
// {{#COMMENTS}}
$_SUCCESS = true;
$_RESULT = \'\';''';

  static final String _templateString = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_STRING({{RUNES}}, '{{STRING}}', {{EXPECTED}});''';

  static final String _templateCharacter = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_CHAR({{RUNE}}, '{{STRING}}', {{EXPECTED}});''';

  LiteralExpression _expression;

  LiteralExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! LiteralExpression) {
      throw new StateError('Expression must be LiteralExpression');
    }

    addTemplate(_TEMPLATE_CHARACTER, _templateCharacter);
    addTemplate(_TEMPLATE_EMPTY, _templateEmpty);
    addTemplate(_TEMPLATE_STRING, _templateString);
  }

  List<String> generate() {
    switch (_expression.text.length) {
      case 0:
        return _generateEmpty();
      case 1:
        return _generateCharacter();
      default:
        return _generateString();
    }
  }

  List<String> _generateEmpty() {
    var block = getTemplateBlock(_TEMPLATE_EMPTY);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    return block.process();
  }

  List<String> _generateCharacter() {
    var block = getTemplateBlock(_TEMPLATE_CHARACTER);
    var text = _expression.text;
    var character = text.runes.toList()[0];
    var string = Utils.charToString(character);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('RUNE', character);
    block.assign('STRING', string);
    block.assign('EXPECTED', ExpressionGenerator.getExpectedOnFailure(_expression));
    return block.process();
  }

  List<String> _generateString() {
    var block = getTemplateBlock(_TEMPLATE_STRING);
    var literal = [];
    var text = _expression.text;
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    for (var charCode in text.codeUnits) {
      literal.add(Utils.charToString(charCode));
    }

    var strings = productionRuleGenerator.parserClassGenerator.addString(text);
    block.assign('EXPECTED', ExpressionGenerator.getExpectedOnFailure(_expression));
    block.assign('RUNES', strings);
    block.assign('STRING', literal.join());
    return block.process();
  }
}
