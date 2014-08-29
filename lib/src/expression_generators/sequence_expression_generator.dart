part of peg.expression_generators;

class SequenceExpressionGenerator extends ListExpressionGenerator {
  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

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
var seq = new List({{COUNT}});
seq[{{INDEX}}] = $_RESULT;''';

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
{{#COMMENTS}}
var {{CH}} = $_CH;
var {{POS}} = $_INPUT_POS;
while (true) {  
  {{#EXPRESSIONS}}
  break;  
}
if (!$_SUCCESS) {
  $_CH = {{CH}};
  $_INPUT_POS = {{POS}};
}''';

  static final String _templateSingle = '''
{{#EXPRESSION}}
{{#ACTION}}''';

  SequenceExpression _expression;

  SequenceExpressionGenerator(Expression expression,
      ProductionRuleGenerator productionRuleGenerator) : super(
      expression,
      productionRuleGenerator) {
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

  List<String> _generateAction(Expression expression) {
    var action = expression.action;
    if (action != null && !action.isEmpty) {
      var variables = _generateSemanticValues(expression);
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
    var ch =
        productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_CH);
    var pos =
        productionRuleGenerator.allocateBlockVariable(ExpressionGenerator.VARIABLE_POS);
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
      inner.assign('#ACTION', _generateAction(expression));
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

    block.assign('CH', ch);
    block.assign('POS', pos);
    return block.process();
  }

  List<String> _generateSemanticValues(Expression expression) {
    var expressions = _expression.expressions;
    var length = expressions.length;
    var position = expression.positionInSequence;
    var strings = [];
    if (length > 1) {
      for (var i = 0; i <= position; i++) {
        if (productionRuleGenerator.comment) {
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
      if (productionRuleGenerator.comment) {
        var expression = expressions[0];
        strings.add("// $expression");
      }

      strings.add("final \$1 = $_RESULT;");
    }

    return strings;
  }

  List<String> _generateSingle() {
    var block = getTemplateBlock(_TEMPLATE_SINGLE);
    block.assign('#EXPRESSION', _generators[0].generate());
    block.assign('#ACTION', _generateAction(_expression.expressions[0]));
    return block.process();
  }
}
