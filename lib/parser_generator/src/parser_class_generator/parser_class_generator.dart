part of peg.parser_generators.parser_class_generator;

abstract class ParserClassGenerator extends ClassGenerator {
  static const int FLAG_TOKEN_VALUE = 1;

  static const String ASCII = "_ascii";

  static const String CACHE = "_cache";

  static const String CACHE_POS = "_cachePos";

  static const String CACHE_RULE = "_cacheRule";

  static const String CACHE_STATE = "_cacheState";

  static const String CH = "_ch";

  static const String CURSOR = "_cursor";

  static const String EOF = "-1";

  static const String ERRORS = "_errors";

  static const String EXPECTED = "_expected";

  static const String FAILURE_POS = "_failurePos";

  static const String INPUT = "_input";

  static const String INPUT_LEN = "_inputLen";

  static const String START_POS = "_startPos";

  static const String SUCCESS = "success";

  static const String TOKEN = "_token";

  static const String TOKEN_FLAGS = "_tokenFlags";

  static const String TOKEN_LEVEL = "_tokenLevel";

  static const String TOKEN_NAMES = "_tokenNames";

  static const String TOKEN_START = "_tokenStart";

  static const String TESTING = "_testing";

  static const String TEXT = "text";

  ParserClassGenerator(String name) : super(name) {
    _addCommonMembers();
  }

  Grammar get grammar;

  ParserGeneratorOptions get options;

  ParserGenerator get parserGenerator;

  void _addCommonMembers() {
    addMethod(new MethodBeginTokenGenerator());
    addMethod(new MethodEndTokenGenerator());
    addMethod(new MethodErrorsGenerator(this));
    addMethod(new MethodFailureGenerator(this));
    addMethod(new MethodFlattenGenerator());
    addMethod(new MethodListGenerator());
    addMethod(new MethodResetGenerator(this));
    addMethod(new MethodTextGenerator());
    addMethod(new MethodToCodePointGenerator());
    addMethod(new MethodToCodePointsGenerator());
    var grammar = parserGenerator.grammar;
    var options = parserGenerator.options;
    // Memoization
    if (options.memoize) {
      addMethod(new MethodAddToCacheGenerator(grammar));
      addMethod(new MethodGetFromCacheGenerator());
    }

    // Variables
    var errorClass = ParserErrorClassGenerator.getName(name);
    var value = "new List<String>.generate(128, (c) => new String.fromCharCode(c))";
    addVariable(new VariableGenerator(ASCII, "static final List<String>", value: value), true);
    addVariable(new VariableGenerator(CACHE, "List"));
    addVariable(new VariableGenerator(CACHE_POS, "int"));
    addVariable(new VariableGenerator(CACHE_RULE, "List<int>"));
    addVariable(new VariableGenerator(CACHE_STATE, "List<int>"));
    addVariable(new VariableGenerator(CH, "int"));
    addVariable(new VariableGenerator(CURSOR, "int"));
    addVariable(new VariableGenerator(ERRORS, "List<$errorClass>"));
    addVariable(new VariableGenerator(EXPECTED, "List<String>"));
    addVariable(new VariableGenerator(FAILURE_POS, "int"));
    addVariable(new VariableGenerator(INPUT, "List<int>"));
    addVariable(new VariableGenerator(INPUT_LEN, "int"));
    addVariable(new VariableGenerator(START_POS, "int"));
    addVariable(new VariableGenerator(SUCCESS, "bool"));
    addVariable(new VariableGenerator(TESTING, "int"));
    addVariable(new VariableGenerator(TOKEN, "int"));
    addVariable(new VariableGenerator(TOKEN_LEVEL, "int"));
    addVariable(new VariableGenerator(TOKEN_START, "int"));
    addVariable(new VariableGenerator(TEXT, "final String"));
    // Generate tokens
    var tokenFlags = <int, int>{};
    var tokenNames = <int, String>{};
    for (var productionRule in grammar.productionRules) {
      if (productionRule.isTerminal) {
        var flag = 0;
        var tokenId = productionRule.tokenId;
        if (productionRule.expression.length == null) {
          flag |= FLAG_TOKEN_VALUE;
        }

        tokenFlags[tokenId] = flag;
        tokenNames[tokenId] = productionRule.getTokenName();
      }
    }

    var length = tokenFlags.length;
    var flags = new List<int>(length);
    var names = new List<String>(length);
    for (var id in tokenFlags.keys) {
      flags[id] = tokenFlags[id];
      names[id] = "\"${Utils.toPrintable(tokenNames[id])}\"";
    }

    addVariable(new VariableGenerator(TOKEN_FLAGS, "final List<int>", value: "[${flags.join(", ")}]"), true);
    addVariable(new VariableGenerator(TOKEN_NAMES, "final List<String>", value: "[${names.join(", ")}]"), true);

    if (grammar.members != null) {
      addCode(Utils.codeToStrings(grammar.members));
    }
  }
}
