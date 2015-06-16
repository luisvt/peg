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

  static const String _TEMPLATE_MILTI_CASE = 'TEMPLATE_MILTI_CASE';

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

  static final String _templateMultiCase = '''
{{#COMMENT}}
{{#CASE}}
  {{#EXPRESSIONS}}
  break;''';

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

  OrderedChoiceExpressionGenerator(
      Expression expression, ProductionRuleGenerator productionRuleGenerator)
      : super(expression, productionRuleGenerator) {
    if (expression is! OrderedChoiceExpression) {
      throw new StateError('Expression must be OrderedChoiceExpression');
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_CASE, _templateCase);
    addTemplate(_TEMPLATE_INNER, _templateInner);
    addTemplate(_TEMPLATE_LAST, _templateLast);
    addTemplate(_TEMPLATE_MILTI_CASE, _templateMultiCase);
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
    var expectedList = expected.toList();
    var length = expectedList.length;
    var printableExpected = [];
    var hasNull = false;
    for (var i = 0; i < length; i++) {
      var element = expectedList[i];
      if (element != null) {
        printableExpected.add(toPrintable(element));
      } else {
        printableExpected = [];
        hasNull = true;
        break;
      }
    }

    if (hasNull) {
      block.assign('EXPECTED', 'const [null]');
    } else {
      block.assign('EXPECTED',
          productionRuleGenerator.parserClassGenerator.addExpected(expected));
    }

    if (options.comment) {
      block.assign('#COMMENT_IN', '// => $_expression # Choice');
      block.assign('#COMMENT_OUT', '// <= $_expression # Choice');
      block.assign(
          '#COMMENT_EXPECTED', '// Expected: ${printableExpected.join(", ")}');
    }

    var states = _generateStates();
    block.assign("#SWITCH", states);
    return block.process();
  }

  List<String> _generateExpressions(List<Expression> expressions) {
    var length = expressions.length;
    if (length == 1) {
      var block = getTemplateBlock(_TEMPLATE_SINGLE);
      var generator =
          createGenerator(expressions.first, productionRuleGenerator);
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
        for (var group in transitions.getAllSpace(range)) {
          var key = group.key;
          if (key == null) {
            key = new _List<Expression>();
          }

          if (!key.contains(expression)) {
            key.add(expression);
          }

          transitions
              .addGroup(new GroupedRangeList(group.start, group.end, key));
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

    final int eofState = states.length + 1;
    final int failState = states.length;
    int singleCharacter;
    RangeList singleRange;
    if (ranges.length == 1) {
      var transition = ranges.first;
      if (transition.length == 1) {
        var range = transition.first;
        if (range.start == range.end) {
          singleCharacter = range.start;
        } else {
          singleRange = range;
        }
      }
    }

    if (singleCharacter != null) {
      var state =
          "$_CH == $singleCharacter ? 0 : $_CH == -1 ? $eofState : $failState";
      blockSwitch.assign("STATE", state);
    } else if (singleRange != null) {
      var start = singleRange.start;
      var end = singleRange.end;
      var state =
          "$_CH >= $start && $_CH <= $end ? 0 : $_CH == -1 ? $eofState : $failState";
      blockSwitch.assign("STATE", state);
    } else {
      var variableName = parserClassGenerator.addTransition(ranges);
      var state = "$_GET_STATE($variableName)";
      blockSwitch.assign("STATE", state);
    }

    var cases = <int, List<String>>{};
    var comments = <int, String>{};
    var length = states.length;
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
    var eof = new _List<Expression>();
    Expression optional;
    var skip = false;
    for (var expression in _expression.expressions) {
      if (expression.canMatchEof || expression.isOptional) {
        eof.add(expression);
        if (!skip) {
          if (expression.isOptional) {
            skip = true;
            optional = expression;
          }
        }
      }
    }

    comments[failState] = "No matches";
    if (optional != null) {
      if (optional is ZeroOrMoreExpression) {
        // TODO: Not tested
        cases[failState] = _generatePredefined("[]", true);
      } else {
        cases[failState] = _generatePredefined("null", true);
      }
    } else {
      cases[failState] = _generatePredefined("null", false);
    }

    var equality = new DeepCollectionEquality();
    comments[eofState] = "EOF";
    // Reduce EOF state code
    if (!eof.isEmpty) {
      int state;
      for (var key in map.keys) {
        if (equality.equals(eof, key)) {
          state = map[key];
          break;
        }
      }

      if (state != null) {
        cases[eofState] = cases[state];
      } else {
        cases[eofState] = _generateExpressions(eof);
      }
    } else {
      cases[eofState] = _generatePredefined("null", false);
    }

    var multiCases = <List<int>>[];
    for (var key in cases.keys) {
      var orginal = cases[key];
      var found = false;
      for (var indexes in multiCases) {
        for (var index in indexes) {
          var other = cases[index];
          if (equality.equals(orginal, other)) {
            indexes.add(key);
            found = true;
            break;
          }
        }
      }

      if (!found) {
        multiCases.add([key]);
      }
    }

    var blockMultiCase = getTemplateBlock(_TEMPLATE_MILTI_CASE);
    for (var keys in multiCases) {
      var block = blockMultiCase.clone();
      for (var key in keys) {
        block.assign("#CASE", "case $key:");
        if (options.comment) {
          var comment = comments[key];
          if (comment != null) {
            block.assign("#COMMENT", "// $comment");
          }
        }
      }

      block.assign("#EXPRESSIONS", cases[keys.first]);
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
