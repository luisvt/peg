part of peg.general_parser.expressions_generators;

class RuleExpressionGenerator extends ExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _LOOKAHEAD = GeneralParserClassGenerator.LOOKAHEAD;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_ELSE = '_TEMPLATE_ELSE';

  static const String _TEMPLATE_ELSE_TRACE = '_TEMPLATE_ELSE_TRACE';

  static const String _TEMPLATE_LOOKAHEAD = 'TEMPLATE_LOOKAHEAD';

  static const String _TEMPLATE_LOOKAHEAD_OPTIONAL = 'TEMPLATE_LOOKAHEAD_OPTIONAL';

  static const String _TEMPLATE_ONE = '_TEMPLATE_ONE';

  static const String _TEMPLATE_ONE_OPTIONAL = '_TEMPLATE_ONE_OPTIONAL';

  static const String _TEMPLATE_PROLOG = '_TEMPLATE_PROLOG';

  static final String _template = '''
{{#COMMENT_IN}}
$_RESULT = {{RULE}}();
{{#COMMENT_OUT}}''';

  static final String _templateElse = '''
else $_SUCCESS = true;''';

  static final String _templateElseTrace = '''
else {
  {{#TRACE}}
  $_SUCCESS = true;
};''';

  // Non optional rule with start characters in lookahead
  static final String _templateLookahead = '''
{{#COMMENT_IN}}
$_RESULT = null;
$_SUCCESS = $_CH >= {{MIN}} && $_CH <= {{MAX}} && $_LOOKAHEAD[$_CH + {{POSITION}}];
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();    
if (!$_SUCCESS) {    
  {{#TRACE}}
  {{#COMMENT_EXPECTED}}    
  if ($_CURSOR > $_TESTING) $_FAILURE({{EXPECTED}});
  {{#BREAK}}  
}
{{#COMMENT_OUT}}''';

  // Optional rule with start characters in lookahead
  static final String _templateLookaheadOptional = '''
{{#COMMENT_IN}}
$_RESULT = null;
$_SUCCESS = $_CH >= {{MIN}} && $_CH <= {{MAX}} && $_LOOKAHEAD[$_CH + {{POSITION}}];
{{#PROLOG}}
{{#COMMENT_OUT}}''';

  // Non optional rule with one start character
  static final String _templateOne = '''
{{#COMMENT_IN}}
$_RESULT = null;
$_SUCCESS = $_CH == {{CHARACTER}}; {{COMMENT_CHARACTER}}
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();
if (!$_SUCCESS) {
  {{#TRACE}}
  {{#COMMENT_EXPECTED}}
  if ($_CURSOR > $_TESTING) $_FAILURE({{EXPECTED}});  
  {{#BREAK}}  
}
{{#COMMENT_OUT}}''';

  // Optional rule with one start character
  static final String _templateOneOptional = '''
{{#COMMENT_IN}}
$_RESULT = null;
$_SUCCESS = $_CH == {{CHARACTER}}; {{COMMENT_CHARACTER}}
{{#PROLOG}}
{{#COMMENT_OUT}}''';

  static final String _templateProlog = '''
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();
{{#ELSE}}''';

  bool _breakOnFailInserted;

  RuleExpression _expression;

  RuleExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! RuleExpression) {
      throw new StateError('Expression must be RuleExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_ELSE, _templateElse);
    addTemplate(_TEMPLATE_ELSE_TRACE, _templateElseTrace);
    addTemplate(_TEMPLATE_LOOKAHEAD, _templateLookahead);
    addTemplate(_TEMPLATE_LOOKAHEAD_OPTIONAL, _templateLookaheadOptional);
    addTemplate(_TEMPLATE_ONE, _templateOne);
    addTemplate(_TEMPLATE_ONE_OPTIONAL, _templateOneOptional);
    addTemplate(_TEMPLATE_PROLOG, _templateProlog);
    _breakOnFailInserted = false;
  }

  bool breakOnFailWasInserted() {
    return _breakOnFailInserted;
  }

  List<String> generate() {
    _breakOnFailInserted = false;
    var rule = _expression.rule;
    if (rule == null) {
      return _generate();
    }

    if (!options.lookahead) {
      return _generate();
    }

    var length = parserClassGenerator.getLookaheadCharCount(rule);
    var expression = rule.expression;
    if (length == 0) {
      return _generate();
    } else if (length == 1) {
      if (!expression.isOptional) {
        return _generateOne();
      } else {
        return _generateOneOptional();
      }

    } else {
      if (!expression.isOptional) {
        return _generateLookahead();
      } else {
        return _generateLookaheadOptional();
      }
    }
  }

  List<String> _generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var rule = _expression.rule;
    block.assign('RULE', '${_getProductionRuleName()}');
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => ${_expression.name}');
      block.assign('#COMMENT_OUT', '// <= ${_expression.name}');
    }

    return block.process();
  }

  List<String> _generateLookahead() {
    var block = getTemplateBlock(_TEMPLATE_LOOKAHEAD);
    var expected = _expression.expectedLexemes;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var lookaheadId = ruleExpression.lookaheadId;
    var position = parserClassGenerator.getLookaheadPosition(lookaheadId);
    var startCharacters = ruleExpression.startCharacters;
    if (options.comment) {
      var name = _expression.name;
      block.assign('#COMMENT_IN', '// => ${_expression.name}');
      block.assign('#COMMENT_OUT', '// <= ${_expression.name}');
      block.assign('#COMMENT_EXPECTED', '// Expected: ${expected.join(", ")}');
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name)');
    }

    if (options.trace) {
      block.assign('#TRACE', _getTraceString());
    }

    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }

    var end = startCharacters.end;
    var start = startCharacters.start;
    block.assign('EXPECTED', _parserClassGenerator.addExpected(expected));
    block.assign('MIN', start);
    block.assign('MAX', end);
    block.assign('POSITION', position - start);
    //block.assign('LOOKAHEAD_ID', lookaheadId * 2);
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  List<String> _generateLookaheadOptional() {
    var block = getTemplateBlock(_TEMPLATE_LOOKAHEAD_OPTIONAL);
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var lookaheadId = ruleExpression.lookaheadId;
    var position = _parserClassGenerator.getLookaheadPosition(lookaheadId);
    var startCharacters = ruleExpression.startCharacters;
    if (options.comment) {
      var comments = [];
      block.assign('#COMMENT_IN', '// => ${_expression.name}');
      block.assign('#COMMENT_OUT', '// <= ${_expression.name}');
    }

    ///*
    if (canInserBreakOnFail()) {
      // Don't insert break because always succeed
      _breakOnFailInserted = true;
    }
    //*/

    block.assign('#PROLOG', _generateProlog());
    var end = startCharacters.end;
    var start = startCharacters.start;
    block.assign('MIN', start);
    block.assign('MAX', end);
    block.assign('POSITION', position - start);
    //block.assign('LOOKAHEAD_ID', lookaheadId * 2);
    return block.process();
  }

  List<String> _generateOne() {
    var block = getTemplateBlock(_TEMPLATE_ONE);
    ;
    var expected = _expression.expectedLexemes;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var character = ruleExpression.startCharacters.start;
    if (options.comment) {
      var name = _expression.name;
      var printable = toPrintable(new String.fromCharCode(character));
      block.assign('COMMENT_CHARACTER', '// \'$printable\'');
      block.assign('#COMMENT_IN', '// => ${_expression.name}');
      block.assign('#COMMENT_OUT', '// <= ${_expression.name}');
      block.assign('#COMMENT_EXPECTED', '// Expected: ${expected.join(", ")}');
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name)');
    } else {
      block.assign('COMMENT_CHARACTER', '');
    }

    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }

    if (options.trace) {
      block.assign('#TRACE', _getTraceString());
    }

    block.assign('CHARACTER', character);
    block.assign('EXPECTED', _parserClassGenerator.addExpected(expected));
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  List<String> _generateOneOptional() {
    var block = getTemplateBlock(_TEMPLATE_ONE_OPTIONAL);
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var character = ruleExpression.startCharacters.start;
    if (options.comment) {
      var printable = toPrintable(new String.fromCharCode(character));
      block.assign('COMMENT_CHARACTER', '// \'$printable\'');
      block.assign('#COMMENT_IN', '// => ${_expression.name}');
      block.assign('#COMMENT_OUT', '// <= ${_expression.name}');
    } else {
      block.assign('COMMENT_CHARACTER', '');
    }

    /*
    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }
    */

    block.assign('#PROLOG', _generateProlog());
    block.assign('CHARACTER', character);
    return block.process();
  }

  List<String> _generateProlog() {
    var block = getTemplateBlock(_TEMPLATE_PROLOG);
    TemplateBlock elseBlock;
    if (options.trace) {
      elseBlock = getTemplateBlock(_TEMPLATE_ELSE_TRACE);
      var state = Trace.getTraceState(skip: true, success: true);
      elseBlock.assign("#TRACE", "$_TRACE('${_expression.name}', '$state');");
    } else {
      elseBlock = getTemplateBlock(_TEMPLATE_ELSE);
    }

    if (options.comment) {
      var name = _expression.name;
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name is optional)');
    }

    block.assign("#ELSE", elseBlock.process());
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  String _getProductionRuleName() {
    var productionRule = _expression.rule;
    if (productionRule == null) {
      return '${ProductionRuleGenerator.PREFIX_PARSE}${_expression.name}';
    }

    return ProductionRuleGenerator.getMethodName(productionRule);
  }

  String _getTraceString() {
    var state = Trace.getTraceState(skip: true, success: false);
    return "$_TRACE('${_expression.name}', '$state');";
  }
}
