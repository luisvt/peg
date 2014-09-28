part of peg.general_parser.expressions_generators;

class CharacterClassExpressionGenerator extends ExpressionGenerator {
  static const String _ASCII = GeneralParserClassGenerator.ASCII;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _MATCH_CHAR = MethodMatchCharGenerator.NAME;

  static const String _MATCH_MAPPING = MethodMatchMappingGenerator.NAME;

  static const String _MATCH_RANGE = MethodMatchRangeGenerator.NAME;

  static const String _MATCH_RANGES = MethodMatchRangesGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE_ASCII = 'TEMPLATE_ASCII';

  static const String _TEMPLATE_ASCII_NON_ASCII = 'TEMPLATE_ASCII_NON_ASCII';

  static const String _TEMPLATE_CHARACTER = 'TEMPLATE_CHARACTER';

  static const String _TEMPLATE_CHARACTER_INLINE = 'TEMPLATE_CHARACTER_INLINE';

  static const String _TEMPLATE_EMPTY = 'TEMPLATE_EMPTY';

  static const String _TEMPLATE_RANGE = 'TEMPLATE_RANGE';

  static const String _TEMPLATE_RANGE_INLINE = 'TEMPLATE_RANGE_INLINE';

  static const String _TEMPLATE_RANGES = 'TEMPLATE_RANGES';

  static final String _templateAscii = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_MAPPING({{MIN}}, {{MAX}}, {{MAPPING}});
{{#COMMENT_OUT}}''';

  static final String _templateAsciiAndNonAscii = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_MAPPING({{MIN}}, {{MAX}}, {{MAPPING}});
if (!$_SUCCESS) {
  $_RESULT = $_MATCH_RANGES({{RANGES}});
}
{{#COMMENT_OUT}}''';

  static final String _templateCharacter = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_CHAR({{RUNE}}, '{{STRING}}');
{{#COMMENT_OUT}}''';

  static final String _templateCharacterInline = '''
{{#COMMENT_IN}}
$_RESULT = '{{STRING}}';
$_SUCCESS = true;
if (++$_CURSOR < $_INPUT_LEN) {
  $_CH = $_INPUT[$_CURSOR];
} else {
  $_CH = $_EOF;
}
{{#COMMENT_OUT}}''';

  static final String _templateEmpty = '''
{{#COMMENT_IN}}
$_SUCCESS = true;
$_RESULT = \'\';
{{#COMMENT_OUT}}''';

  static final String _templateRange = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_RANGE({{MIN}}, {{MAX}});
{{#COMMENT_OUT}}''';

  static final String _templateRangeInline = '''
{{#COMMENT_IN}}
$_SUCCESS = $_CH != -1;
if ($_SUCCESS) {
  if ($_CH < 128) {
    $_RESULT = $_ASCII[$_CH];  
  } else {
    $_RESULT = new String.fromCharCode($_CH);
  }        
  if (++$_CURSOR < $_INPUT_LEN) {
    $_CH = $_INPUT[$_CURSOR];
  } else {
    $_CH = $_EOF;
  }  
} else $_RESULT = null;
{{#COMMENT_OUT}}''';

  static final String _templateRanges = '''
{{#COMMENT_IN}}
$_RESULT = $_MATCH_RANGES({{RANGES}});
{{#COMMENT_OUT}}''';

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
    addTemplate(_TEMPLATE_CHARACTER_INLINE, _templateCharacterInline);
    addTemplate(_TEMPLATE_EMPTY, _templateEmpty);
    addTemplate(_TEMPLATE_RANGE, _templateRange);
    addTemplate(_TEMPLATE_RANGE_INLINE, _templateRangeInline);
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
    if (_expression.positionInSequence == 0) {
      // TODO: Optimize
    }

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
    var range = parserClassGenerator.addMapping(_ascii);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('MAX', _ascii.end);
    block.assign('MAPPING', range);
    block.assign('MIN', _ascii.start);
    return block.process();
  }

  List<String> _generateAsciiAndNonAscii() {
    var block = getTemplateBlock(_TEMPLATE_ASCII_NON_ASCII);
    var mapping = parserClassGenerator.addMapping(_ascii);
    var ranges = parserClassGenerator.addRanges(_nonAscii);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('MAX', _ascii.end);
    block.assign('MIN', _ascii.start);
    block.assign('MAPPING', mapping);
    block.assign('RANGES', ranges);
    return block.process();
  }

  List<String> _generateCharacter() {
    if (isFirstBarrage(_expression)) {
      return _generateCharacterInline();
    }

    var block = getTemplateBlock(_TEMPLATE_CHARACTER);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    var string = Utils.charToString(_singleCharacter);
    block.assign('RUNE', _singleCharacter);
    block.assign('STRING', string);
    return block.process();
  }

  List<String> _generateCharacterInline() {
    var block = getTemplateBlock(_TEMPLATE_CHARACTER_INLINE);
    var string = Utils.charToString(_singleCharacter);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('STRING', string);
    return block.process();
  }

  List<String> _generateEmpty() {
    var block = getTemplateBlock(_TEMPLATE_EMPTY);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    return block.process();
  }

  List<String> _generateRange() {
    if (isFirstBarrage(_expression)) {
      //return _generateRangeInline();
    }

    var block = getTemplateBlock(_TEMPLATE_RANGE);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('MAX', _singleRange.end);
    block.assign('MIN', _singleRange.start);
    return block.process();
  }

  List<String> _generateRangeInline() {
    var block = getTemplateBlock(_TEMPLATE_RANGE_INLINE);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    return block.process();
  }

  List<String> _generateRanges() {
    var block = getTemplateBlock(_TEMPLATE_RANGES);
    var ranges = parserClassGenerator.addRanges(_nonAscii);
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression');
      block.assign('#COMMENT_OUT', '// <= $_expression');
    }

    block.assign('RANGES', ranges);
    return block.process();
  }
}
