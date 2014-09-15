part of peg.expression_generators;

class CharacterClassExpressionGenerator extends ExpressionGenerator {
  static const String _CH = GeneralParserClassGenerator.VARIABLE_CH;

  static const String _CUSROR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_LEN = GeneralParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _MATCH_CHAR = MethodMatchCharGenerator.NAME;

  static const String _MATCH_MAPPING = MethodMatchMappingGenerator.NAME;

  static const String _MATCH_RANGE = MethodMatchRangeGenerator.NAME;

  static const String _MATCH_RANGES = MethodMatchRangesGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GeneralParserClassGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE_ASCII = 'TEMPLATE_ASCII';

  static const String _TEMPLATE_ASCII_NON_ASCII = 'TEMPLATE_ASCII_NON_ASCII';

  static const String _TEMPLATE_CHARACTER = 'TEMPLATE_CHARACTER';

  static const String _TEMPLATE_EMPTY = 'TEMPLATE_EMPTY';

  static const String _TEMPLATE_RANGE = 'TEMPLATE_RANGE';

  static const String _TEMPLATE_RANGES = 'TEMPLATE_RANGES';

  static final String _templateAscii = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_MAPPING({{MIN}}, {{MAX}}, {{MAPPING}});''';

  static final String _templateAsciiAndNonAscii = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_MAPPING({{MIN}}, {{MAX}}, {{MAPPING}});
if (!$_SUCCESS) {
  $_RESULT = $_MATCH_RANGES({{RANGES}});
}''';

  static final String _templateCharacter = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_CHAR({{RUNE}}, '{{STRING}}');''';

  static final String _templateEmpty = '''
// {{#COMMENTS}}
$_SUCCESS = true;
$_RESULT = \'\';''';

  static final String _templateRange = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_RANGE({{MIN}}, {{MAX}});''';

  static final String _templateRanges = '''
{{#COMMENTS}}
$_RESULT = $_MATCH_RANGES({{RANGES}});''';

  SparseBoolList _ascii;

  CharacterClassExpression _expression;

  bool _hasAscii;

  bool _hasNonAscii;

  SparseBoolList _nonAscii;

  int _singleCharacter;

  RangeList _singleRange;

  CharacterClassExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! CharacterClassExpression) {
      throw new StateError('Expression must be CharacterClassExpression');
    }

    addTemplate(_TEMPLATE_ASCII, _templateAscii);
    addTemplate(_TEMPLATE_ASCII_NON_ASCII, _templateAsciiAndNonAscii);
    addTemplate(_TEMPLATE_CHARACTER, _templateCharacter);
    addTemplate(_TEMPLATE_EMPTY, _templateEmpty);
    addTemplate(_TEMPLATE_RANGE, _templateRange);
    addTemplate(_TEMPLATE_RANGES, _templateRanges);
    var ranges = _expression.ranges;
    _ascii = new SparseBoolList();
    _nonAscii = new SparseBoolList();
    for (var group in ranges.groups) {
      _ascii.addGroup(group);
      _nonAscii.addGroup(group);
    }

    _ascii.removeValues(Expression.nonAsciiGroup);
    _nonAscii.removeValues(Expression.asciiGroup);
    _ascii.trim();
    _nonAscii.trim();
    _hasAscii = false;
    _hasNonAscii = false;
    if (_ascii.length > 0) {
      _hasAscii = true;
    }

    if (_nonAscii.length > 0) {
      _hasNonAscii = true;
    }

    _singleCharacter;
    _singleRange;
    var groups = ranges.groups;
    if (groups.length == 1) {
      var group = groups[0];
      if (group.start == group.end) {
        _singleCharacter = group.start;
      } else {
        _singleRange = group;
      }
    }
  }

  List<String> generate() {
    if (_singleCharacter != null) {
      return _generateCharacter();
    } else if (_singleRange != null) {
      return _generateRange();
    } else if (_hasAscii && !_hasNonAscii) {
      return _generateAscii();
    } else if (_hasAscii && _hasNonAscii) {
      return _generateAsciiAndNonAscii();
    } else if (_hasNonAscii) {
      return _generateRanges();
    } else {
      return _generateEmpty();
    }
  }

  List<String> _generateAscii() {
    var block = getTemplateBlock(_TEMPLATE_ASCII);
    var range = productionRuleGenerator.parserClassGenerator.addMapping(_ascii);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('MAX', _ascii.end);
    block.assign('MAPPING', range);
    block.assign('MIN', _ascii.start);
    return block.process();
  }

  List<String> _generateAsciiAndNonAscii() {
    var block = getTemplateBlock(_TEMPLATE_ASCII_NON_ASCII);
    var parserClassGenerator = productionRuleGenerator.parserClassGenerator;
    var mapping = parserClassGenerator.addMapping(_ascii);
    var ranges = parserClassGenerator.addRanges(_nonAscii);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('MAX', _ascii.end);
    block.assign('MIN', _ascii.start);
    block.assign('MAPPING', mapping);
    block.assign('RANGES', ranges);
    return block.process();
  }

  List<String> _generateCharacter() {
    var block = getTemplateBlock(_TEMPLATE_CHARACTER);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    var string = Utils.charToString(_singleCharacter);
    block.assign('RUNE', _singleCharacter);
    block.assign('STRING', _singleCharacter);
    return block.process();
  }

  List<String> _generateEmpty() {
    var block = getTemplateBlock(_TEMPLATE_EMPTY);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    return block.process();
  }

  List<String> _generateRange() {
    var block = getTemplateBlock(_TEMPLATE_RANGE);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('MAX', _singleRange.end);
    block.assign('MIN', _singleRange.start);
    return block.process();
  }

  List<String> _generateRanges() {
    var block = getTemplateBlock(_TEMPLATE_RANGES);
    var ranges = productionRuleGenerator.parserClassGenerator.addRanges(_nonAscii);
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// $_expression');
    }

    block.assign('RANGES', ranges);
    return block.process();
  }
}
