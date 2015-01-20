part of peg.general_parser.expressions_generators;

class SequenceExpressionGenerator extends ListExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _START_POS = ParserClassGenerator.START_POS;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE_ACTION = 'TEMPLATE_ACTION';

  static const String _TEMPLATE_FIRST = 'TEMPLATE_FIRST';

  static const String _TEMPLATE_INNER = 'TEMPLATE_INNER';

  static const String _TEMPLATE_LAST = 'TEMPLATE_LAST';

  static const String _TEMPLATE_OUTER = 'TEMPLATE_OUTER';

  static const String _TEMPLATE_SINGLE = 'TEMPLATE_SINGLE';

  static final String _templateAction = '''
if ($_SUCCESS) {    
  {{#VARIABLES}}
  {{#CODE}}
}''';

  static final String _templateFirst = '''
{{#EXPRESSION}}
{{#BREAK}}
{{#ACTION}}
var seq = new List({{COUNT}})..[{{INDEX}}] = $_RESULT;''';

  static final String _templateInner = '''
{{#EXPRESSION}}
{{#BREAK}}
{{#ACTION}}
seq[{{INDEX}}] = $_RESULT;''';

  static final String _templateLast = '''
{{#EXPRESSION}}
{{#BREAK}}
seq[{{INDEX}}] = $_RESULT;
$_RESULT = seq;
{{#ACTION}}''';

  static final String _templateOuter = '''
{{#COMMENT_IN}}
var {{CH}} = $_CH, {{POS}} = $_CURSOR, {{START_POS}} = $_START_POS;
$_START_POS = $_CURSOR;
while (true) {  
  {{#EXPRESSIONS}}
  break;
}
if (!$_SUCCESS) {
  $_CH = {{CH}};
  $_CURSOR = {{POS}};
}
$_START_POS = {{START_POS}};
{{#COMMENT_OUT}}''';

  static final String _templateSingle = '''
{{#COMMENT_IN}}
var {{START_POS}} = $_START_POS;
$_START_POS = $_CURSOR;
{{#EXPRESSION}}
{{#ACTION}}
$_START_POS = {{START_POS}};
{{#COMMENT_OUT}}''';

  SequenceExpression _expression;

  SequenceExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! SequenceExpression) {
      throw new StateError('Expression must be SequenceExpression');
    }

    addTemplate(_TEMPLATE_ACTION, _templateAction);
    addTemplate(_TEMPLATE_FIRST, _templateFirst);
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

  List<String> _generateAction(Expression expression, startPos) {
    var action = expression.action;
    if (action != null) {
      var variables = _generateSemanticValues(expression, startPos);
      var block = getTemplateBlock(_TEMPLATE_ACTION);
      block.assign('#CODE', Utils.codeToStrings(action));
      block.assign('#VARIABLES', variables);
      return block.process();
    }

    return [];
  }

  List<String> _generateSeveral() {
    var block = getTemplateBlock(_TEMPLATE_OUTER);
    var expressions = _expression.expressions;
    var length = expressions.length;
    var ch = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.CH);
    var pos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.POS);
    var startPos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.START_POS);
    for (var i = 0; i < length; i++) {
      TemplateBlock inner;
      var generator = _generators[i];
      var expression = expressions[i];
      if (i == 0) {
        inner = getTemplateBlock(_TEMPLATE_FIRST);
        inner.assign('COUNT', length);
      } else if (i != length - 1) {
        inner = getTemplateBlock(_TEMPLATE_INNER);
      } else {
        inner = getTemplateBlock(_TEMPLATE_LAST);
      }

      inner.assign('#EXPRESSION', generator.generate());
      inner.assign('#ACTION', _generateAction(expression, startPos));
      inner.assign('INDEX', i);
      if (!generator.breakOnFailWasInserted()) {
        inner.assign('#BREAK', 'if (!$_SUCCESS) break;');
      } else {
        //print("=======================");
        //print("${_expression}: can break;");
        //print("${generator._expression}: can break;");
      }

      block.assign('#EXPRESSIONS', inner.process());
    }

    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression # Sequence');
      block.assign('#COMMENT_OUT', '// <= $_expression # Sequence');
    }

    block.assign('CH', ch);
    block.assign('POS', pos);
    block.assign('START_POS', startPos);
    return block.process();
  }

  List<String> _generateSemanticValues(Expression expression, String startPos) {
    var expressions = _expression.expressions;
    var length = expressions.length;
    var position = expression.positionInSequence;
    var strings = [];
    if (length > 1) {
      for (var i = 0; i <= position; i++) {
        if (options.comment) {
          var expression = expressions[i];
          strings.add("// $expression");
        }

        if (i == position && position != length - 1) {
          strings.add("final \$${i + 1} = $_RESULT;");
        } else {
          strings.add("final \$${i + 1} = seq[${i}];");
        }
      }
    } else {
      if (options.comment) {
        var expression = expressions[0];
        strings.add("// $expression");
      }

      strings.add("final \$1 = $_RESULT;");
    }

    strings.add("final \$start = $startPos;");
    return strings;
  }

  List<String> _generateSingle() {
    var block = getTemplateBlock(_TEMPLATE_SINGLE);
    var startPos = productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.START_POS);
    if (options.comment) {
      // TODO: Remove
      //block.assign('#COMMENT_IN', '// => $_expression # Sequence');
      //block.assign('#COMMENT_OUT', '// <= $_expression # Sequence');
    }

    block.assign('#EXPRESSION', _generators[0].generate());
    block.assign('#ACTION', _generateAction(_expression.expressions[0], startPos));
    block.assign('START_POS', startPos);
    return block.process();
  }
}
