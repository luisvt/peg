part of peg.general_parser.parser_class_generator;

class GeneralParserClassGenerator extends ParserClassGenerator {
  static const String EXPECT = "_expect";

  static const String LOOKAHEAD = "_lookahead";

  static const String MAPPING = "_mapping";

  static const String RANGE = "_range";

  static const String RANGES = "_ranges";

  static const String STRINGS = "_strings";

  static const String TRANSITIONS = "_transitions";

  static const String _UNMAP = MethodUnmapGenerator.NAME;

  final Grammar grammar;

  final GeneralParserGenerator parserGenerator;

  List<List<String>> _expected = <List<String>>[];

  List<ProductionRuleGenerator> _generators = <ProductionRuleGenerator>[];

  Grammar _grammar;

  Map<int, dynamic> _lookaheadRules = new Map<int, dynamic>();

  List<int> _lookaheadTable = <int>[];

  List<SparseBoolList> _mappings = <SparseBoolList>[];

  List<SparseBoolList> _ranges = <SparseBoolList>[];

  List<String> _strings = <String>[];

  List<List<List<int>>> _transitions = <List<List<int>>>[];

  GeneralParserClassGenerator(String name, this.grammar, this.parserGenerator) : super(name) {
    if (grammar == null) {
      throw new ArgumentError('grammar: $grammar');
    }

    if (parserGenerator == null) {
      throw new ArgumentError('parser: $parserGenerator');
    }

    _optimizeLookaheads();
  }

  ParserGeneratorOptions get options => parserGenerator.options;

  String addExpected(Iterable<String> expected) {
    if (expected == null) {
      throw new ArgumentError('expected: $expected');
    }

    var list = expected.toList();
    list.sort((a, b) {
      if (a == null) {
        return -1;
      }

      if (b == null) {
        return 1;
      }

      return a.compareTo(b);
    });

    var count = _expected.length;
    var length = list.length;
    for (var i = 0; i < count; i++) {
      var current = _expected[i];
      if (current.length != length) {
        continue;
      }

      var equal = true;
      for (var i = 0; i < length; i++) {
        if (current[i] != list[i]) {
          equal = false;
        }
      }

      if (equal) {
        return '$EXPECT$i';
      }
    }

    _expected.add(list);
    return '$EXPECT${_expected.length - 1}';
  }

  String addMapping(SparseBoolList range) {
    if (range == null) {
      throw new ArgumentError('range: $range');
    }

    var count = _mappings.length;
    var length = range.length;
    for (var i = 0; i < count; i++) {
      var current = _mappings[i];
      if (current.length != length) {
        continue;
      }

      var equal = true;
      for (var i = 0; i < length; i++) {
        if (current[i] != range[i]) {
          equal = false;
        }
      }

      if (equal) {
        return '$MAPPING$i';
      }
    }

    _mappings.add(range);
    return '$MAPPING${_mappings.length - 1}';
  }

  String addRanges(SparseBoolList ranges) {
    if (ranges == null) {
      throw new ArgumentError('ranges: $ranges');
    }

    _ranges.add(ranges);
    return '$RANGES${_ranges.length - 1}';
  }

  String addString(String string) {
    if (string == null) {
      throw new ArgumentError('string: $string');
    }

    var length = _strings.length;
    var found = false;
    var i = 0;
    for ( ; i < length; i++) {
      if (string == _strings[i]) {
        found = true;
        break;
      }
    }

    if (!found) {
      i = length;
      _strings.add(string);
    }

    return '$STRINGS$i';
  }

  String addTransition(List<List<RangeList>> transitions) {
    var i = _transitions.length;
    var list = <List<int>>[];
    for (var transition in transitions) {
      var ranges = <int>[];
      for (var range in transition) {
        ranges.add(range.start);
        ranges.add(range.end);
      }

      list.add(ranges);
    }

    var length = _transitions.length;
    for (var i = 0; i < length; i++) {
      var ranges = _transitions[i];
      if (ranges.length == list.length) {
        var length2 = ranges.length;
        var failed = false;
        for (var j = 0; j < length2; j++) {
          var l1 = ranges[j];
          var l2 = list[j];
          var length3 = l1.length;
          if (l2.length != length3) {
            failed = true;
            break;
          }

          for (var k = 0; k < length3; k++) {
            if (l1[k] != l2[k]) {
              failed = true;
              break;
            }
          }

          if (failed) {
            break;
          }
        }

        if (!failed) {
          return '$TRANSITIONS$i';
        }
      }
    }

    _transitions.add(list);
    return '$TRANSITIONS$i';
  }

  List<String> generate() {
    // Constructor
    addConstructor(new ClassContructorGenerator(name));
    //
    var processed = new Set<String>();
    for (var productionRule in grammar.productionRules) {
      var name = productionRule.name;
      if (!processed.contains(name)) {
        addMethod(new ProductionRuleGenerator(productionRule, this));
      }

      processed.add(productionRule.name);
    }

    addMethod(new MethodGetStateGenerator());
    addMethod(new MethodMatchAnyGenerator());
    addMethod(new MethodMatchCharGenerator());
    addMethod(new MethodMatchMappingGenerator());
    addMethod(new MethodMatchRangeGenerator());
    addMethod(new MethodMatchRangesGenerator());
    addMethod(new MethodMatchStringGenerator());
    addMethod(new MethodNextCharGenerator());
    addMethod(new MethodUnmapGenerator());
    // Trace
    if (options.trace) {
      // Max length of production rule name
      var length = 0;
      for (var rule in grammar.productionRules) {
        var name = rule.name;
        if (length < name.length) {
          length = name.length;
        }
      }

      addMethod(new MethodTraceGenerator(length));
    }

    _generateVariables();
    return super.generate();
  }

  int getLookaheadPosition(int id) {
    var lookahead = _lookaheadRules[id];
    if (lookahead == null) {
      throw new StateError('lookahead with id ($id) not found');
    }

    return lookahead['start'];
  }

  int getLookaheadCharCount(ProductionRule rule) {
    if (rule == null) {
      throw new ArgumentError("rule: $rule");
    }

    var expression = rule.expression;
    if (expression.isOptional) {
      if (expression.hasActions) {
        return 0;
      }
    }

    if (expression.startsWithAny || expression.startsWithNonAscii) {
      return 0;
    }

    var startCharacters = expression.startCharacters;
    var characters = startCharacters.getIndexes().toList();
    if (characters.length == 0) {
      return 0;
    }

    // TODO: check standalone characters
    return characters.last - characters.first + 1;
  }

  void _generateVariables() {
    if (!_lookaheadTable.isEmpty) {
      var packed = _pack(_lookaheadTable);
      var hex = packed.map((e) => "0x" + e.toRadixString(16));
      var value = "$_UNMAP([${hex.join(', ')}])";
      addVariable(new VariableGenerator(LOOKAHEAD, "static final List<bool>", value: value), true);
    }

    if (!_mappings.isEmpty) {
      var length = _mappings.length;
      for (var i = 0; i < length; i++) {
        var charList = [];
        var commentList = [];
        var range = _mappings[i];
        var charCode = range.start;
        var end = range.end;
        var count = end - charCode + 1;
        var source = new List<int>.filled(count, 0);
        for (var i = 0; charCode <= end; charCode++, i++) {
          if (range[charCode]) {
            if (options.comment) {
              var string = "'${Utils.charToString(charCode)}'";
              commentList.add(string);
            }
            source[i] = 1;
          }
        }

        String comment;
        if (options.comment) {
          comment = "// ${commentList.join(", ")}";
        }

        var packed = _pack(source);
        var hex = packed.map((e) => "0x" + e.toRadixString(16));
        var value = "$_UNMAP([${hex.join(', ')}])";
        addVariable(new VariableGenerator("$MAPPING$i", "static final List<bool>", comment: comment, value: value), true);
      }
    }

    if (!_ranges.isEmpty) {
      var length = _ranges.length;
      for (var i = 0; i < length; i++) {
        var list = [];
        var range = _ranges[i];
        for (var group in range.groups) {
          list.add(group.start);
          list.add(group.end);
        }

        var value = "<int>[${list.join(', ')}]";
        addVariable(new VariableGenerator("$RANGES$i", "static final List<int>", value: value), true);
      }
    }

    if (!_strings.isEmpty) {
      var length = _strings.length;
      for (var i = 0; i < length; i++) {
        var string = _strings[i];
        var list = string.runes.toList();
        String comment;
        if (options.comment) {
          comment = "// '${toPrintable(string)}'";
        }

        var value = "<int>[${list.join(', ')}]";
        addVariable(new VariableGenerator("$STRINGS$i", "static final List<int>", comment: comment, value: value), true);
      }
    }

    if (!_expected.isEmpty) {
      var length = _expected.length;
      for (var i = 0; i < length; i++) {
        var expected = Utils.toPrintableList(_expected[i]);

        var value = "<String>[${expected.join(', ')}]";
        addVariable(new VariableGenerator("$EXPECT$i", "static final List<String>", value: value), true);
      }
    }

    if (!_transitions.isEmpty) {
      var length = _transitions.length;
      for (var i = 0; i < length; i++) {
        var value = Utils.listToPrintableString(_transitions[i]);
        addVariable(new VariableGenerator("$TRANSITIONS$i", "static final List<List<int>>", value: value), true);
      }
    }
  }

  void _optimizeLookaheads() {
    var list = [];
    var lookaheadIds = 0;
    var lookaheads = [];
    var rules = grammar.productionRules;
    for (ProductionRule rule in rules) {
      var length = getLookaheadCharCount(rule);
      if (length == 0) {
        continue;
      }

      var expression = rule.expression;
      var startCharacters = expression.startCharacters;
      var characters = startCharacters.getIndexes().toList();
      expression.lookaheadId = lookaheadIds++;
      var lookaheadId = expression.lookaheadId;
      var filled = new List<int>.filled(length, 0);
      var index = startCharacters.start;
      for (var i = 0; i < length; i++) {
        if (startCharacters[index++]) {
          filled[i] = 1;
        }
      }

      lookaheads.add({
        'id': lookaheadId,
        'filled': filled,
        'size': length
      });
    }

    lookaheads.sort((a, b) => b['size'] - a['size']);
    var number = lookaheads.length;
    for (var i = 0; i < number; i++) {
      var combined = false;
      var lookahead = lookaheads[i];
      var filled = lookahead['filled'];
      var size = filled.length;
      var total = _lookaheadTable.length;
      var j;
      for (j = 0; j < total; j++) {
        if (size > total - j) {
          break;
        }

        var k;
        for (k = 0; k < size; k++) {
          if (filled[k] != _lookaheadTable[j + k]) {
            break;
          }
        }

        if (k == size) {
          combined = true;
          break;
        }
      }

      if (!combined) {
        lookahead['start'] = _lookaheadTable.length;
        _lookaheadTable.addAll(filled);
      } else {
        lookahead['start'] = j;
      }
    }

    for (var lookahead in lookaheads) {
      _lookaheadRules[lookahead['id']] = lookahead;
    }
  }

  List<int> _pack(List<int> source) {
    const BITS_PER_WORD = 31;
    var length = source.length ~/ BITS_PER_WORD;
    if (source.length % BITS_PER_WORD != 0) {
      length++;
    }

    var offset = 0;
    var packed = new List<int>.filled(length, 0);
    length = source.length;
    for (var bitPosition = 0,
        i = 0; i < length; i++) {
      var bit = source[i];
      if (bit != 0) {
        packed[offset] |= 1 << bitPosition;
      }

      if (++bitPosition == BITS_PER_WORD) {
        bitPosition = 0;
        offset++;
      }
    }

    return packed;
  }
}
