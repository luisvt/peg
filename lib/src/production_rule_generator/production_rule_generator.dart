part of peg.production_rule_generator;

class ProductionRuleGenerator extends TemplateGenerator {
  static const String VARIABLE_RESULT = "\$\$";

  static const String _ADD_TO_CACHE = MethodAddToCacheGenerator.NAME;

  static const String _CACHE_POS = GeneralParserClassGenerator.VARIABLE_CACHE_POS;

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _GET_FROM_CACHE = MethodGetFromCacheGenerator.NAME;

  static const String _RESULT = VARIABLE_RESULT;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TOKEN = GeneralParserClassGenerator.VARIABLE_TOKEN;

  static const String _TOKEN_LEVEL = GeneralParserClassGenerator.VARIABLE_TOKEN_LEVEL;

  static const String _TOKEN_START = GeneralParserClassGenerator.VARIABLE_TOKEN_START;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _TEMPLATE_TOKEN_EPILOG = '_TEMPLATE_TOKEN_EPILOG';

  static const String _TEMPLATE_TOKEN_PROLOG = '_TEMPLATE_TOKEN_PROLOG';

  static const String _TEMPLATE_WITH_CACHE = '_TEMPLATE_WITH_CACHE';

  static const String _TEMPLATE_WITHOUT_CACHE = '_TEMPLATE_WITHOUT_CACHE';

  static const String _TEMPLATE = '_TEMPLATE';

  static const String _TEMPLATE_TEST_RULE = '_TEMPLATE_TEST_RULE';

  static const String PREFIX_PARSE = 'parse_';

  static String _templateTokenEpilog = '''
if (--$_TOKEN_LEVEL == 0) {
  $_TOKEN = null;
  $_TOKEN_START = null;
}''';

  static String _templateTokenProlog = '''
if ($_TOKEN_LEVEL++ == 0) {
  $_TOKEN = {{TOKEN}};
  $_TOKEN_START = $_CURSOR;
}''';

  static String _templateWithCache = '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}
  {{#VARIABLES}}        
  var pos = $_CURSOR;    
  if(pos <= $_CACHE_POS) {
    $_RESULT = $_GET_FROM_CACHE({{RULE_ID}});
  }
  if($_RESULT != null) {
    {{#LEAVE_CACHED}}
    return $_RESULT[0];       
  }  
  {{#TOKEN_PROLOG}}    
  {{#EXPRESSION}}
  $_ADD_TO_CACHE($_RESULT, pos, {{RULE_ID}});
  {{#TOKEN_EPILOG}}
  {{#LEAVE}}        
  return $_RESULT;
}
''';

  static String _templateWithoutCache = '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}  
  {{#VARIABLES}}
  {{#TOKEN_PROLOG}}  
  {{#EXPRESSION}}
  {{#TOKEN_EPILOG}}
  {{#LEAVE}}    
  return $_RESULT;
}
''';

  Map<String, int> _blockVariables = new Map<String, int>();

  OrderedChoiceExpressionGenerator _expressionGenerator;

  bool _comment;

  List<Generator> generators = [];

  GeneralParserClassGenerator _parserClassGenerator;

  bool _memoize;

  ProductionRule _productionRule;

  Map<String, int> _variables = new Map<String, int>();

  ProductionRuleGenerator(ProductionRule productionRule, GeneralParserClassGenerator parserClassGenerator) {
    if (productionRule == null) {
      throw new ArgumentError('productionRule: $productionRule');
    }

    if (parserClassGenerator == null) {
      throw new ArgumentError('parserClassGenerator: $parserClassGenerator');
    }

    _parserClassGenerator = parserClassGenerator;
    _memoize = parserClassGenerator.parserGenerator.memoize;
    _productionRule = productionRule;
    _expressionGenerator = new OrderedChoiceExpressionGenerator(productionRule.expression, this);
    _comment = parserClassGenerator.parserGenerator.comment;
    addTemplate(_TEMPLATE_TOKEN_EPILOG, _templateTokenEpilog);
    addTemplate(_TEMPLATE_TOKEN_PROLOG, _templateTokenProlog);
    addTemplate(_TEMPLATE_WITH_CACHE, _templateWithCache);
    addTemplate(_TEMPLATE_WITHOUT_CACHE, _templateWithoutCache);
  }

  static String getMethodName(ProductionRule productionRule) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    if (!productionRule.isStartingRule) {
      return '_${PREFIX_PARSE}${productionRule.name}';
    }

    return '${PREFIX_PARSE}${productionRule.name}';
  }

  bool get comment {
    return _comment;
  }

  String get name {
    return getMethodName(_productionRule);
  }

  GeneralParserClassGenerator get parserClassGenerator {
    return _parserClassGenerator;
  }

  String allocateVariable(String name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (_variables[name] == null) {
      _variables[name] = 0;
    }

    return '$name${_variables[name]++}';
  }

  String allocateBlockVariable(String name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (_blockVariables[name] == null) {
      _blockVariables[name] = 0;
    }

    return '$name${_blockVariables[name]++}';
  }

  List<String> generate() {
    var useCache = _memoize;
    if (_productionRule.directCallers.length < 2) {
      useCache = false;
    }

    if (useCache) {
      return _generateWithCache();
    } else {
      return _generateWithoutCache();
    }
  }

  void _assignTraceVariables(TemplateBlock block) {
    var name = _productionRule.name;
    block.assign('#ENTER', "$_TRACE('$name', '${Trace.getTraceState(enter: true, success: true)}');");
    var success = Trace.getTraceState(enter: false, success: true);
    var failed = Trace.getTraceState(enter: false, success: false);
    block.assign('#LEAVE', "$_TRACE('$name', ($_SUCCESS ? '$success' : '$failed'));");
  }

  void _assignTraceVariablesWithCache(TemplateBlock block) {
    var name = _productionRule.name;
    block.assign('#ENTER', "$_TRACE('$name', '${Trace.getTraceState(enter: true, success: true)}');");
    var success = Trace.getTraceState(cached: true, enter: false, success: true);
    var failed = Trace.getTraceState(cached: true, enter: false, success: false);
    block.assign('#LEAVE_CACHE', "$_TRACE('$name', ($_SUCCESS ? '$success' : '$failed'));");
  }

  List<String> _generateTokenEpilog() {
    if (!_productionRule.isTerminal) {
      return const <String>[];
    }

    var block = getTemplateBlock(_TEMPLATE_TOKEN_EPILOG);
    return block.process();
  }

  List<String> _generateTokenProlog() {
    if (!_productionRule.isTerminal) {
      return const <String>[];
    }

    var block = getTemplateBlock(_TEMPLATE_TOKEN_PROLOG);
    var name = Utils.toPrintable(_productionRule.getTokenName());
    block.assign("TOKEN", "\"$name\"");
    return block.process();
  }

  List<String> _generateVariables() {
    var strings = [];
    for (var name in _variables.keys) {
      var last = _variables[name];
      var names = [];
      for (var i = 0; i <= last; i++) {
        names.add('$name$i');
      }

      strings.add('var ${names.join(', ')};');
    }

    strings.add('var $_RESULT;');
    return strings;
  }

  List<String> _generateWithCache() {
    var block = getTemplateBlock(_TEMPLATE_WITH_CACHE);
    var methodName = getMethodName(_productionRule);
    if (comment) {
      var lexical = _productionRule.isTerminal ? 'TERMINAL' : 'NONTERMINAL';
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $_productionRule');
    }

    if (_productionRule.isTerminal) {
      block.assign('#TOKEN_EPILOG', _generateTokenEpilog());
      block.assign('#TOKEN_PROLOG', _generateTokenProlog());
    }

    if (parserClassGenerator.parserGenerator.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);

    var block2 = new TemplateBlock(_templateWithCache);
    block.assign('RULE_ID', _productionRule.id);
    return block.process();
  }

  List<String> _generateWithoutCache() {
    var block = getTemplateBlock(_TEMPLATE_WITHOUT_CACHE);
    var methodName = getMethodName(_productionRule);
    if (comment) {
      var lexical = _productionRule.isTerminal ? 'TERMINAL' : 'NONTERMINAL';
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $_productionRule');
    }

    if (_productionRule.isTerminal) {
      block.assign('#TOKEN_EPILOG', _generateTokenEpilog());
      block.assign('#TOKEN_PROLOG', _generateTokenProlog());
    }

    if (parserClassGenerator.parserGenerator.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);
    return block.process();
  }
}
