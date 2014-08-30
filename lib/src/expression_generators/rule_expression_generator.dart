part of peg.expression_generators;

class RuleExpressionGenerator extends ExpressionGenerator {
  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _CURSOR = GrammarGenerator.VARIABLE_CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _LOOKAHEAD = GrammarGenerator.VARIABLE_LOOKAHEAD;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GrammarGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_ELSE = '_TEMPLATE_ELSE';

  static const String _TEMPLATE_ELSE_TRACE = '_TEMPLATE_ELSE_TRACE';

  static const String _TEMPLATE_LOOKAHEAD = 'TEMPLATE_LOOKAHEAD';

  static const String _TEMPLATE_LOOKAHEAD_OPTIONAL =
      'TEMPLATE_LOOKAHEAD_OPTIONAL';

  static const String _TEMPLATE_ONE = '_TEMPLATE_ONE';

  static const String _TEMPLATE_ONE_OPTIONAL = '_TEMPLATE_ONE_OPTIONAL';

  static const String _TEMPLATE_PROLOG = '_TEMPLATE_PROLOG';

  static final String _template = '''
{{#COMMENTS}}
$_RESULT = {{RULE}}();''';

  static final String _templateElse = '''
else $_SUCCESS = true;''';

  static final String _templateElseTrace = '''
else {
  {{#TRACE}}
  $_SUCCESS = true;
};''';

  // Non optional rule with start characters in lookahead
  static final String _templateLookahead = '''
{{#COMMENTS}}
$_RESULT = null;
$_SUCCESS = $_CH >= {{MIN}} && $_CH <= {{MAX}} && $_LOOKAHEAD[$_CH + {{POSITION}}];
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();    
if (!$_SUCCESS) {  
  {{#TRACE}}  
  if ($_CURSOR > $_TESTING) $_FAILURE({{EXPECTED}});
  {{#BREAK}}  
}''';

  // Optional rule with start characters in lookahead
  static final String _templateLookaheadOptional = '''
{{#COMMENTS}}
$_RESULT = null;
$_SUCCESS = $_CH >= {{MIN}} && $_CH <= {{MAX}} && $_LOOKAHEAD[$_CH + {{POSITION}}];
{{#PROLOG}}''';

  // Non optional rule with one start character
  static final String _templateOne = '''
{{#COMMENTS}}
$_RESULT = null;
$_SUCCESS = $_CH == {{CHARACTER}}; {{COMMENT_CHARACTER}}
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();
if (!$_SUCCESS) {
  {{#TRACE}}
  if ($_CURSOR > $_TESTING) $_FAILURE({{EXPECTED}});
  {{#BREAK}}  
}''';

  // Optional rule with one start character
  static final String _templateOneOptional = '''
{{#COMMENTS}}
$_RESULT = null;
$_SUCCESS = $_CH == {{CHARACTER}}; {{COMMENT_CHARACTER}}
{{#PROLOG}}''';

  static final String _templateProlog = '''
{{#LOOKAHEAD_COMMENTS}}
if ($_SUCCESS) $_RESULT = {{RULE}}();
{{#ELSE}}''';

  RuleExpression _expression;

  bool _breakOnFailInserted;

  RuleExpressionGenerator(Expression expression,
      ProductionRuleGenerator productionRuleGenerator) : super(
      expression,
      productionRuleGenerator) {
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

    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    if (!grammarGenerator.parserGenerator.lookahead) {
      return _generate();
    }

    var length = grammarGenerator.getLookaheadCharCount(rule);
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
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// ${_expression.name}');
    }

    return block.process();
  }

  List<String> _generateLookahead() {
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var lookaheadId = ruleExpression.lookaheadId;
    var position = grammarGenerator.getLookaheadPosition(lookaheadId);
    var startCharacters = ruleExpression.startCharacters;
    block = getTemplateBlock(_TEMPLATE_LOOKAHEAD);
    block.assign(
        'EXPECTED',
        ExpressionGenerator.getExpectedOnFailure(ruleExpression));
    if (productionRuleGenerator.comment) {
      var name = _expression.name;
      block.assign('#COMMENTS', '// ${_expression.name}');
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name)');
    }

    if (grammarGenerator.parserGenerator.trace) {
      block.assign('#TRACE', _getTraceString());
    }

    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }

    var end = startCharacters.end;
    var start = startCharacters.start;
    block.assign('MIN', start);
    block.assign('MAX', end);
    block.assign('POSITION', position - start);
    //block.assign('LOOKAHEAD_ID', lookaheadId * 2);
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  List<String> _generateLookaheadOptional() {
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var lookaheadId = ruleExpression.lookaheadId;
    var position = grammarGenerator.getLookaheadPosition(lookaheadId);
    var startCharacters = ruleExpression.startCharacters;
    block = getTemplateBlock(_TEMPLATE_LOOKAHEAD_OPTIONAL);
    if (productionRuleGenerator.comment) {
      var comments = [];
      block.assign('#COMMENTS', '// ${_expression.name}');
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
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var character = ruleExpression.startCharacters.start;
    var trace = grammarGenerator.parserGenerator.trace;
    block = getTemplateBlock(_TEMPLATE_ONE);
    block.assign(
        'EXPECTED',
        ExpressionGenerator.getExpectedOnFailure(ruleExpression));
    if (productionRuleGenerator.comment) {
      var name = _expression.name;
      var printable = toPrintable(new String.fromCharCode(character));
      block.assign('COMMENT_CHARACTER', '// \'$printable\'');
      block.assign('#COMMENTS', '// ${_expression.name}');
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name)');
    } else {
      block.assign('COMMENT_CHARACTER', '');
    }

    if (canInserBreakOnFail()) {
      block.assign('#BREAK', "break;");
      _breakOnFailInserted = true;
    }

    if (trace) {
      block.assign('#TRACE', _getTraceString());
    }

    block.assign('CHARACTER', character);
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  List<String> _generateOneOptional() {
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var character = ruleExpression.startCharacters.start;
    var trace = grammarGenerator.parserGenerator.trace;
    block = getTemplateBlock(_TEMPLATE_ONE_OPTIONAL);
    if (productionRuleGenerator.comment) {
      var printable = toPrintable(new String.fromCharCode(character));
      block.assign('COMMENT_CHARACTER', '// \'$printable\'');
      block.assign('#COMMENTS', '// ${_expression.name}');
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
    if (productionRuleGenerator.grammarGenerator.parserGenerator.trace) {
      elseBlock = getTemplateBlock(_TEMPLATE_ELSE_TRACE);
      var state = Trace.getTraceState(skip: true, success: true);
      elseBlock.assign(
          "#TRACE",
          "$_TRACE('${_expression.name}', '$state');");
    } else {
      elseBlock = getTemplateBlock(_TEMPLATE_ELSE);
    }

    if (productionRuleGenerator.comment) {
      var name = _expression.name;
      block.assign('#LOOKAHEAD_COMMENTS', '// Lookahead ($name is optional)');
    }

    block.assign("#ELSE", elseBlock.process());
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  String _getProductionRuleName() {
    return '${ProductionRuleGenerator.PREFIX_PARSE}${_expression.name}';
  }

  String _getTraceString() {
    var state = Trace.getTraceState(skip: true, success: false);
    return "$_TRACE('${_expression.name}', '$state');";
  }
}
