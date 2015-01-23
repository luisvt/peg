part of peg.parser_generators.parser_class_generator;

abstract class ParserClassGenerator extends ClassGenerator {
  static const int FLAG_TOKEN_VALUE = 1;

  static const String ASCII = "_ascii";

  static const String CACHE = "_cache";

  static const String CACHE_POS = "_cachePos";

  static const String CACHEABLE = "_cacheable";

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

  static const String TESTING = "_testing";

  static const String TOKEN = "_token";

  static const String TOKEN_ALIASES = "_tokenAliases";

  static const String TOKEN_FLAGS = "_tokenFlags";

  static const String TOKEN_NAMES = "_tokenNames";

  static const String TOKEN_START = "_tokenStart";

  static const String TEXT = "text";

  ParserClassGenerator(String name) : super(name) {
    _addCommonMembers();
  }

  Grammar get grammar;

  ParserGeneratorOptions get options;

  ParserGenerator get parserGenerator;

  void _addCommonMembers() {
    var grammar = parserGenerator.grammar;
    var options = parserGenerator.options;
    addMethod(new MethodErrorsGenerator(this));
    addMethod(new MethodFailureGenerator(this));
    addMethod(new MethodFlattenGenerator());
    addMethod(new MethodListGenerator());
    // TODO: Use the real number of memoized rules
    addMethod(new MethodResetGenerator(this, grammar.productionRules.length));
    addMethod(new MethodTextGenerator());
    addMethod(new MethodToCodePointGenerator());
    addMethod(new MethodToCodePointsGenerator());
    // Memoization
    if (options.memoize) {
      addMethod(new MethodAddToCacheGenerator(grammar));
      addMethod(new MethodGetFromCacheGenerator());
    }

    // Variables
    var errorClass = ParserErrorClassGenerator.getName(name);
    var value = "new List<String>.generate(128, (c) => new String.fromCharCode(c))";
    addVariable(new VariableGenerator(ASCII, "static final List<String>", value: value), true);
    addVariable(new VariableGenerator(CACHE, "List<Map<int, List>>"));
    addVariable(new VariableGenerator(CACHE_POS, "List<int>"));
    addVariable(new VariableGenerator(CACHEABLE, "List<bool>"));
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
    addVariable(new VariableGenerator(TOKEN_START, "int"));
    addVariable(new VariableGenerator(TEXT, "final String"));
    // Generate tokens
    var tokenAliases = <int, String>{};
    var tokenFlags = <int, int>{};
    var tokenNames = <int, String>{};
    for (var productionRule in grammar.productionRules) {
      if (productionRule.isLexeme) {
        var flag = 0;
        var tokenId = productionRule.tokenId;
        if (productionRule.expression.maxLength == null) {
          flag |= FLAG_TOKEN_VALUE;
        }

        tokenFlags[tokenId] = flag;
        // TODO: productionRule.getTokenName()
        // tokenNames[tokenId] = productionRule.getTokenName();
        var name = productionRule.name;
        var alias = productionRule.getTokenName();
        /*
        tokenAliases[tokenId] = alias;
        if (name == name.toUpperCase()) {
          name = name.toLowerCase();
        } else if (!name.contains("_")) {
          name = underscore(name);
        } else {
          name = name.toLowerCase();
        }

        name = name.replaceAll("_", " ");
        */
        tokenAliases[tokenId] = alias;
        tokenNames[tokenId] = name;
      }
    }

    var length = tokenFlags.length;
    var flags = new List<int>(length);
    var aliases = new List<String>(length);
    var names = new List<String>(length);
    for (var id in tokenFlags.keys) {
      flags[id] = tokenFlags[id];
      aliases[id] = "\"${Utils.toPrintable(tokenAliases[id])}\"";
      names[id] = "\"${Utils.toPrintable(tokenNames[id])}\"";
    }

    addVariable(new VariableGenerator(TOKEN_ALIASES, "final List<String>", value: "[${aliases.join(", ")}]"), true);
    addVariable(new VariableGenerator(TOKEN_FLAGS, "final List<int>", value: "[${flags.join(", ")}]"), true);
    addVariable(new VariableGenerator(TOKEN_NAMES, "final List<String>", value: "[${names.join(", ")}]"), true);

    if (grammar.members != null) {
      addCode(Utils.codeToStrings(grammar.members));
    }
  }
}
