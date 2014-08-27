part of peg.expression_generators;

class RuleExpressionGenerator extends ExpressionGenerator {
  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _LOOKAHEAD = GrammarGenerator.VARIABLE_LOOKAHEAD;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GrammarGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_ONE = '_TEMPLATE_ONE';

  static const String _TEMPLATE_SEVERAL = 'TEMPLATE_SEVERAL';

  static const String _TEMPLATE_LOOKAHEAD = 'TEMPLATE_LOOKAHEAD';

  static const String _TEMPLATE_SWITCH = 'TEMPLATE_SWITCH';

  static final String _template = '''
{{#COMMENTS}}
$_RESULT = {{RULE}}();''';

  // Non optional rule with start characters in lookahead
  static final String _templateLookahead = '''
{{#COMMENTS}}
if ($_CH >= {{MIN}} && $_CH <= {{MAX}} && $_LOOKAHEAD[$_CH + {{POSITION}}]) {
  $_RESULT = {{RULE}}();
}    
else {
  $_SUCCESS = false;  
  $_RESULT = null;
  {{#TRACE}}  
  if ($_INPUT_POS > $_TESTING) $_FAILURE({{EXPECTED}});  
}''';

  // Non optional rule with one start character
  static final String _templateOne = '''
{{#COMMENTS}}
if ($_CH == {{CHARACTER}}) $_RESULT = {{RULE}}();
else {  
 $_SUCCESS = false;
 $_RESULT = null;
 {{#TRACE}}
 if ($_INPUT_POS > $_TESTING) $_FAILURE({{EXPECTED}});  
}''';

  // Non optional rule with several start characters
  static final String _templateSeveral = '''
{{#COMMENTS}}
var {{SKIP}} = true;
{{#SWITCH}}
if (!{{SKIP}}) $_RESULT = {{RULE}}();
else {
 $_RESULT = null;
 $_SUCCESS = false;
 {{#TRACE}}
 if ($_INPUT_POS > $_TESTING) $_FAILURE({{EXPECTED}});  
}''';

  static final String _templateSwitch = '''
switch ($_CH) {
  {{#CASE}}
    {{SKIP}} = false;      
    break;  
}''';

  RuleExpression _expression;

  RuleExpressionGenerator(Expression expression,
      ProductionRuleGenerator productionRuleGenerator) : super(
      expression,
      productionRuleGenerator) {
    if (expression is! RuleExpression) {
      throw new StateError('Expression must be RuleExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_LOOKAHEAD, _templateLookahead);
    addTemplate(_TEMPLATE_ONE, _templateOne);
    addTemplate(_TEMPLATE_SEVERAL, _templateSeveral);
    addTemplate(_TEMPLATE_SWITCH, _templateSwitch);
  }

  List<String> generate() {
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
      return _generateOne();
    } else if (length <= ParserGenerator.LOOKAHEAD_CHAR_COUNT) {
      return _generateSeveral();
    } else {
      return _generateLookahead();
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
      block.assign('#COMMENTS', '// ${_expression.name}');
    }

    if (grammarGenerator.parserGenerator.trace) {
      block.assign('#TRACE', _getTraceString());
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

  List<String> _generateOne() {
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var character = ruleExpression.startCharacters.start;
    block = getTemplateBlock(_TEMPLATE_ONE);
    block.assign(
        'EXPECTED',
        ExpressionGenerator.getExpectedOnFailure(ruleExpression));
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// ${_expression.name}');
    }

    if (grammarGenerator.parserGenerator.trace) {
      block.assign('#TRACE', _getTraceString());
    }

    block.assign('CHARACTER', character);
    block.assign('RULE', '${_getProductionRuleName()}');
    return block.process();
  }

  List<String> _generateSeveral() {
    TemplateBlock block;
    var grammarGenerator = productionRuleGenerator.grammarGenerator;
    var sblock = getTemplateBlock(_TEMPLATE_SWITCH);
    var characters = [];
    var rule = _expression.rule;
    var ruleExpression = rule.expression;
    var skip =
        productionRuleGenerator.allocateBlockVariable(
            ExpressionGenerator.VARIABLE_SKIP);
    var startCharacters = ruleExpression.startCharacters.getIndexes().toList();
    var length = startCharacters.length;
    block = getTemplateBlock(_TEMPLATE_SEVERAL);
    block.assign(
        'EXPECTED',
        ExpressionGenerator.getExpectedOnFailure(ruleExpression));
    for (var i = 0; i < length; i++) {
      sblock.assign('#CASE', 'case ${startCharacters[i]}:');
    }

    block.assign('RULE', '${_getProductionRuleName()}');
    if (productionRuleGenerator.comment) {
      block.assign('#COMMENTS', '// ${_expression.name}');
    }

    if (grammarGenerator.parserGenerator.trace) {
      block.assign('#TRACE', _getTraceString());
    }

    block.assign('SKIP', skip);
    sblock.assign('SKIP', skip);
    block.assign('#SWITCH', sblock.process());
    return block.process();
  }

  String _getProductionRuleName() {
    return '${ProductionRuleGenerator.PREFIX_PARSE}${_expression.name}';
  }

  String _getTraceString() {
    return "$_TRACE('${_expression.name}', '><*');";
  }
}
