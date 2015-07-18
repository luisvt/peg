part of peg.general_parser.expressions_generators;

class LiteralExpressionGenerator extends ExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _MATCH_CHAR = MethodMatchCharGenerator.NAME;

  static const String _MATCH_STRING = MethodMatchStringGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE_CHARACTER = 'TEMPLATE_CHARACTER';

  static const String _TEMPLATE_EMPTY = 'TEMPLATE_EMPTY';

  static const String _TEMPLATE_STRING = 'TEMPLATE_STRING';

  static final String _templateEmpty = '''
{{#COMMENT_IN}}
$_SUCCESS = true;
$_RESULT = \'\';
{{#COMMENT_OUT}}''';

  static final String _templateString = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_STRING({{CODE_POINTS}}, '{{STRING}}');
{{#COMMENT_OUT}}''';

  static final String _templateCharacter = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_CHAR({{CODE_POINT}}, '{{STRING}}');
{{#COMMENT_OUT}}''';

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
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    return block.process();
  }

  List<String> _generateCharacter() {
    var block = getTemplateBlock(_TEMPLATE_CHARACTER);
    var text = _expression.text;
    var character = text.runes.toList()[0];
    var string = Utils.charToString(character);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('CODE_POINT', character);
    block.assign('STRING', string);
    return block.process();
  }

  List<String> _generateString() {
    var block = getTemplateBlock(_TEMPLATE_STRING);
    var literal = [];
    var text = _expression.text;
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    for (var charCode in text.codeUnits) {
      literal.add(Utils.charToString(charCode));
    }

    var strings = productionRuleGenerator.parserClassGenerator.addString(text);
    block.assign('CODE_POINTS', strings);
    block.assign('STRING', literal.join());
    return block.process();
  }
}
