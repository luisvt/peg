part of peg.general_parser.expressions_generators;

class OrderedChoiceExpressionGenerator extends ListExpressionGenerator {
  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _GET_STATE = "_getState";

  static const String _RESULT = ProductionRuleGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = 'TEMPLATE';

  static const String _TEMPLATE_CASE = 'TEMPLATE_CASE';

  static const String _TEMPLATE_INNER = 'TEMPLATE_INNER';

  static const String _TEMPLATE_LAST = 'TEMPLATE_LAST';

  static const String _TEMPLATE_OUTER = 'TEMPLATE_OUTER';

  static const String _TEMPLATE_PREDEFINED = 'TEMPLATE_PREDEFINED';

  static const String _TEMPLATE_SINGLE = 'TEMPLATE_SINGLE';

  static const String _TEMPLATE_SWITCH = 'TEMPLATE_SWITCH';

  static final String _template = '''
{{#COMMENT_IN}}
{{#SWITCH}}
if (!$_SUCCESS && $_CURSOR > $_TESTING) {
  {{#COMMENT_EXPECTED}}
  $_FAILURE({{EXPECTED}});
}
{{#COMMENT_OUT}}''';

  static final String _templateCase = '''
{{#COMMENT}}
case {{VALUE}}:
  {{#EXPRESSIONS}}
  break;''';

  static final String _templateInner = '''
{{#EXPRESSION}}
if ($_SUCCESS) break;''';

  static final String _templateLast = '''
{{#EXPRESSION}}''';

  static final String _templateOuter = '''
while (true) {
  {{#EXPRESSIONS}}
  break;
}''';

  static final String _templatePredefined = '''
$_RESULT = {{RESULT}};
$_SUCCESS = {{SUCCESS}};''';

  static final String _templateSingle = '''
{{#EXPRESSION}}''';

  static final String _templateSwitch = '''
switch ({{STATE}}) {
  {{#CASES}}
}''';

  OrderedChoiceExpression _expression;

  OrderedChoiceExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! OrderedChoiceExpression) {
      throw new StateError('Expression must be OrderedChoiceExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_CASE, _templateCase);
    addTemplate(_TEMPLATE_INNER, _templateInner);
    addTemplate(_TEMPLATE_LAST, _templateLast);
    addTemplate(_TEMPLATE_OUTER, _templateOuter);
    addTemplate(_TEMPLATE_PREDEFINED, _templatePredefined);
    addTemplate(_TEMPLATE_SINGLE, _templateSingle);
    addTemplate(_TEMPLATE_SWITCH, _templateSwitch);
  }

  List<String> generate() {
    switch (_expression.expressions.length) {
      case 0:
        throw new StateError('The expressions list has zero length');
      default:
        return _generate();
    }
  }

  List<String> _generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var expected = _expression.expectedLexemes;
    block.assign('EXPECTED', productionRuleGenerator.parserClassGenerator.addExpected(expected));
    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression # Choice');
      block.assign('#COMMENT_OUT', '// <= $_expression # Choice');
      block.assign('#COMMENT_EXPECTED', '// Expected: ${expected.join(", ")}');
    }

    var states = _generateStates();
    block.assign("#SWITCH", states);
    return block.process();
  }

  List<String> _generateExpressions(List<Expression> expressions) {
    var length = expressions.length;
    if (length == 1) {
      var block = getTemplateBlock(_TEMPLATE_SINGLE);
      var generator = createGenerator(expressions.first, productionRuleGenerator);
      block.assign("#EXPRESSION", generator.generate());
      return block.process();
    }

    var block = getTemplateBlock(_TEMPLATE_OUTER);
    for (var i = 0; i < length; i++) {
      var expression = expressions[i];
      TemplateBlock inner;
      if (i != length - 1) {
        inner = getTemplateBlock(_TEMPLATE_INNER);
      } else {
        inner = getTemplateBlock(_TEMPLATE_LAST);
      }

      var generator = createGenerator(expression, productionRuleGenerator);
      inner.assign('#EXPRESSION', generator.generate());
      block.assign('#EXPRESSIONS', inner.process());
    }

    return block.process();
  }

  List<String> _generatePredefined(String result, bool success) {
    var block = getTemplateBlock(_TEMPLATE_PREDEFINED);
    block.assign("RESULT", result);
    block.assign("SUCCESS", success.toString());
    return block.process();
  }

  List<String> _generateStates() {
    var blockSwitch = getTemplateBlock(_TEMPLATE_SWITCH);
    var transitions = new SparseList<List<Expression>>();
    for (var expression in _expression.expressions) {
      for (var range in expression.startCharacters.groups) {
        for (var group in transitions.getAlignedGroups(range)) {
          var key = group.key;
          if (key == null) {
            key = new _List<Expression>();
          }

          if (!key.contains(expression)) {
            key.add(expression);
          }

          transitions.addGroup(new GroupedRangeList(group.start, group.end, key));
        }
      }
    }

    var map = <_List, int>{};
    var states = <List<Expression>>[];
    var ranges = <List<RangeList>>[];
    for (var group in transitions.groups) {
      var key = group.key;
      var state = map[key];
      if (state == null) {
        state = states.length;
        states.add(new List<Expression>.from(key));
        map[key] = state;
      }

      if (ranges.length < state + 1) {
        ranges.add(<RangeList>[group]);
      } else {
        ranges[state].add(group);
      }
    }

    int singleCharacter;
    if (ranges.length == 1) {
      var transition = ranges.first;
      if (transition.length == 1) {
        var range = transition.first;
        if (range.start == range.end) {
          singleCharacter = range.start;
        }
      }
    }

    if (singleCharacter != null) {
      var state = "$_CH == $singleCharacter ? 0 : $_CH == -1 ? 1 : -1";
      blockSwitch.assign("STATE", state);
    } else {
      var variableName = parserClassGenerator.addTransition(ranges);
      var state = "$_GET_STATE($variableName)";
      blockSwitch.assign("STATE", state);
    }

    var cases = <int, List<String>>{};
    var comments = <int, String>{};
    var length = states.length;
    var blockCase = getTemplateBlock(_TEMPLATE_CASE);
    for (var i = 0; i < length; i++) {
      var expressions = states[i];
      cases[i] = _generateExpressions(expressions);
      if (options.comment) {
        var comment = <String>[];
        for (var range in ranges[i]) {
          if (range.start == range.end) {
            var start = Utils.charToString(range.start);
            comment.add("[$start]");
          } else {
            var start = Utils.charToString(range.start);
            var end = Utils.charToString(range.end);
            comment.add("[$start-$end]");
          }
        }

        comments[i] = comment.join(" ");
      }
    }

    // EOF list
    var eof = <Expression>[];
    Expression optional;
    for (var expression in _expression.expressions) {
      if (expression.canMatchEof) {
        eof.add(expression);
      }

      if (expression.isOptional) {
        eof.add(expression);
        optional = expression;
        break;
      }
    }

    comments[states.length] = "EOF";
    if (!eof.isEmpty) {
      cases[states.length] = _generateExpressions(eof);
    } else {
      cases[states.length] = _generatePredefined("null", false);
    }

    comments[-1] = "No matches";
    if (optional != null) {
      if (optional is ZeroOrMoreExpression) {
        // TODO: Not tested
        cases[-1] = _generatePredefined("[]", true);
      } else {
        cases[-1] = _generatePredefined("null", true);
      }

    } else {
      cases[-1] = _generatePredefined("null", false);
    }

    for (var key in cases.keys) {
      var block = blockCase.clone();
      if (options.comment) {
        var comment = comments[key];
        if (comment != null) {
          block.assign("#COMMENT", "// $comment");
        }
      }

      block.assign("VALUE", key);
      block.assign("#EXPRESSIONS", cases[key]);
      blockSwitch.assign("#CASES", block.process());
    }

    return blockSwitch.process();
  }
}

// TODO: Move to another location
class _List<T> extends Object with ListMixin<T> {
  List<T> _source = <T>[];

  int get hashCode => 0;

  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is _List) {
      var length = this.length;
      if (length != other.length) {
        return false;
      }

      for (var i = 0; i < length; i++) {
        if (_source[i] != other[i]) {
          return false;
        }
      }

      return true;
    }

    return false;
  }

  T operator [](int index) {
    return _source[index];
  }

  void operator []=(int index, T value) {
    _source[index] = value;
  }

  int get length => _source.length;

  void set length(int length) {
    _source.length = length;
  }
}
