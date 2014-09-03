part of peg.grammar_generator;

class ParserClassGenerator extends TemplateGenerator {
  static const int FLAG_TOKENIZATION = 1;

  static const String CONSTANT_EOF = "EOF";

  static const String VARIABLE_CACHE = "_cache";

  static const String VARIABLE_CACHE_POS = "_cachePos";

  static const String VARIABLE_CACHE_RULE = "_cacheRule";

  static const String VARIABLE_CACHE_STATE = "_cacheState";

  static const String VARIABLE_CH = "_ch";

  static const String VARIABLE_COLUMN = "_column";

  static const String VARIABLE_CURSOR = "_cursor";

  static const String VARIABLE_EXPECTED = "_expected";

  static const String VARIABLE_FAILURE_POS = "_failurePos";

  static const String VARIABLE_FLAG = "_flag";

  static const String VARIABLE_INPUT_LEN = "_inputLen";

  static const String VARIABLE_LINE = "_line";

  static const String VARIABLE_LOOKAHEAD = "_lookahead";

  static const String VARIABLE_MAPPING = "_mapping";

  static const String VARIABLE_RANGE = "_range";

  static const String VARIABLE_RANGES = "_ranges";

  static const String VARIABLE_RUNES = "_runes";

  static const String VARIABLE_STRINGS = "_strings";

  static const String VARIABLE_SUCCESS = "success";

  static const String VARIABLE_TESTING = "_testing";

  static const String _UNMAP = MethodUnmapGenerator.NAME;

  final String name;

  final Grammar grammar;

  final ParserGenerator parserGenerator;

  List<ProductionRuleGenerator> _generators = [];

  Map<int, dynamic> _lookaheadRules = new Map<int, dynamic>();

  List<int> _lookaheadTable = new List<int>();

  List<SparseBoolList> _mappings = [];

  List<SparseBoolList> _ranges = [];

  List<String> _strings = [];

  ParserClassGenerator(this.name, this.grammar, this.parserGenerator) {
    if (name == null) {
      throw new ArgumentError('name: $name');
    }

    if (grammar == null) {
      throw new ArgumentError('grammar: $grammar');
    }

    if (parserGenerator == null) {
      throw new ArgumentError('parser: $parserGenerator');
    }

    _optimizeLookaheads();
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
        return '$VARIABLE_MAPPING$i';
      }
    }

    _mappings.add(range);
    return '$VARIABLE_MAPPING${_mappings.length - 1}';
  }

  String addRanges(SparseBoolList ranges) {
    if (ranges == null) {
      throw new ArgumentError('ranges: $ranges');
    }

    _ranges.add(ranges);
    return '$VARIABLE_RANGES${_ranges.length - 1}';
  }

  String addString(String string) {
    if (string == null) {
      throw new ArgumentError('string: $string');
    }

    var length = _strings.length;
    var found = false;
    var i = 0;
    for(; i < length; i++) {
      if(string == _strings[i]) {
        found = true;
        break;
      }
    }

    if(!found) {
      i = length;
      _strings.add(string);
    }

    return '$VARIABLE_STRINGS${i}';
  }

  List<String> generate() {
    var constructors = [new ClassContructorGenerator(name).generate()];
    var generators = <String, Generator>{};
    var methods = [];
    for (var rule in grammar.rules) {
      var generator = new ProductionRuleGenerator(rule, this);
      generators[generator.getMethodName()] = generator;
    }

    methods.addAll(_generateInSortOrder(generators));
    generators.clear();

    // Cache
    var size = (grammar.rules.length >> 5) + 1;
    if (size != size << 5) {
      size++;
    }
    generators[MethodAddToCacheGenerator.NAME] = new MethodAddToCacheGenerator(size);
    generators[MethodGetFromCacheGenerator.NAME] = new MethodGetFromCacheGenerator();
    // Position
    generators[MethodCalculatePosGenerator.NAME] = new MethodCalculatePosGenerator();
    // Errors
    generators[MethodExpectedGenerator.NAME] = new MethodExpectedGenerator();
    generators[MethodFailureGenerator.NAME] = new MethodFailureGenerator();
    // Helpers
    generators[MethodFlattenGenerator.NAME] = new MethodFlattenGenerator();
    // Matchers
    generators[MethodMatchAnyGenerator.NAME] = new MethodMatchAnyGenerator();
    generators[MethodMatchCharGenerator.NAME] = new MethodMatchCharGenerator();
    generators[MethodMatchMappingGenerator.NAME] = new MethodMatchMappingGenerator();
    generators[MethodMatchRangeGenerator.NAME] = new MethodMatchRangeGenerator();
    generators[MethodMatchRangesGenerator.NAME] = new MethodMatchRangesGenerator();
    generators[MethodMatchStringGenerator.NAME] = new MethodMatchStringGenerator();
    // Next char
    generators[MethodNextCharGenerator.NAME] = new MethodNextCharGenerator();
    // Reset
    generators[MethodResetGenerator.NAME] = new MethodResetGenerator();
    // Test char
    // TODO: MethodTestCharGenerator used?
    generators[MethodTestCharGenerator.NAME] = new MethodTestCharGenerator();
    // Test input
    // TODO: MethodTestInputGenerator use?
    generators[MethodTestInputGenerator.NAME] = new MethodTestInputGenerator();
    // Unexpected
    generators[MethodUnexpectedGenerator.NAME] = new MethodUnexpectedGenerator();
    // Utility
    generators[MethodUnmapGenerator.NAME] = new MethodUnmapGenerator();
    // Trace
    if (parserGenerator.trace) {
      var length = 0;
      for (var rule in grammar.rules) {
        var name = rule.name;
        if (length < name.length) {
          length = name.length;
        }
      }

      generators[MethodTraceGenerator.NAME] = new MethodTraceGenerator(length);
    }

    // Helper methods
    generators[MethodRuneAtGenerator.NAME] = new MethodRuneAtGenerator();
    generators[MethodToRunesGenerator.NAME] = new MethodToRunesGenerator();

    methods.addAll(_generateInSortOrder(generators));
    if (parserGenerator.grammar.members != null) {
      methods.add(Utils.codeToStrings(parserGenerator.grammar.members));
    }

    // Accessors
    generators.clear();
    generators[AccessorColumnGenerator.NAME] = new AccessorColumnGenerator();
    generators[AccessorLineGenerator.NAME] = new AccessorLineGenerator();
    // Properties
    var properties = _generateInSortOrder(generators);
    var variables = _generateVariables();
    var classGenerator = new ClassGenerator(constructors: constructors, methods: methods, name: name, properties: properties, variables: variables);
    return classGenerator.generate();
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

  List<List<String>> _generateInSortOrder(Map<String, Generator> generators) {
    var result = <List<String>>[];
    var names = generators.keys.toList();
    names.sort((a, b) => a.compareTo(b));
    for (var name in names) {
      result.add(generators[name].generate());
    }

    return result;
  }

  List<String> _generateVariables() {
    var strings = [];
    strings.add('static const int $CONSTANT_EOF = -1;');
    if (!_lookaheadTable.isEmpty) {
      var packed = _pack(_lookaheadTable);
      var hex = packed.map((e) => "0x" + e.toRadixString(16));
      strings.add('static final List<bool> $VARIABLE_LOOKAHEAD = $_UNMAP([${hex.join(', ')}]);');
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
            if (parserGenerator.comment) {
              var string = "'${Utils.charToString(charCode)}'";
              commentList.add(string);
            }
            source[i] = 1;
          }
        }

        if (parserGenerator.comment) {
          strings.add('// ${commentList.join(", ")}');
        }

        var packed = _pack(source);
        var hex = packed.map((e) => "0x" + e.toRadixString(16));
        strings.add('static final List<bool> $VARIABLE_MAPPING$i = $_UNMAP([${hex.join(', ')}]);');
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

        strings.add('static final List<int> $VARIABLE_RANGES$i = <int>[${list.join(', ')}];');
      }
    }

    if (!_strings.isEmpty) {
      var length = _strings.length;
      for (var i = 0; i < length; i++) {
        var string = _strings[i];
        var list = string.runes.toList();
        if (parserGenerator.comment) {
          strings.add('// "${toPrintable(string)}"');
        }

        strings.add('static final List<int> $VARIABLE_STRINGS$i = <int>[${list.join(', ')}];');
      }
    }

    strings.add('List $VARIABLE_CACHE;');
    strings.add('int $VARIABLE_CACHE_POS;');
    strings.add('List<int> $VARIABLE_CACHE_RULE;');
    strings.add('List<int> $VARIABLE_CACHE_STATE;');
    strings.add('int $VARIABLE_CH;');
    strings.add('int $VARIABLE_COLUMN;');
    strings.add('int $VARIABLE_CURSOR;');
    strings.add('List<String> $VARIABLE_EXPECTED;');
    strings.add('int $VARIABLE_FAILURE_POS;');
    strings.add('int $VARIABLE_FLAG;');
    strings.add('int $VARIABLE_INPUT_LEN;');
    strings.add('int $VARIABLE_LINE;');
    strings.add('List<int> $VARIABLE_RUNES;');
    strings.add('bool $VARIABLE_SUCCESS;');
    strings.add('int $VARIABLE_TESTING;');
    strings.add('');
    return strings;
  }

  void _optimizeLookaheads() {
    var list = [];
    var lookaheadIds = 0;
    var lookaheads = [];
    var rules = grammar.rules;
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
