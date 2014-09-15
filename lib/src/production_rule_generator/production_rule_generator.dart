part of peg.production_rule_generator;

class ProductionRuleGenerator extends TemplateGenerator {
  static const String VARIABLE_RESULT = "\$\$";

  static const String _ADD_TO_CACHE = MethodAddToCacheGenerator.NAME;

  static const String _CACHE_POS = GeneralParserClassGenerator.VARIABLE_CACHE_POS;

  static const String _CURSOR = GeneralParserClassGenerator.VARIABLE_CURSOR;

  static const String _FLAG = GeneralParserClassGenerator.VARIABLE_FLAG;

  static const String _GET_FROM_CACHE = MethodGetFromCacheGenerator.NAME;

  static const String _RESULT = VARIABLE_RESULT;

  static const String _SUCCESS = GeneralParserClassGenerator.VARIABLE_SUCCESS;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _TEMPLATE_WITH_CACHE = '_TEMPLATE_WITH_CACHE';

  static const String _TEMPLATE_WITHOUT_CACHE = '_TEMPLATE_WITHOUT_CACHE';

  static const String _TEMPLATE = '_TEMPLATE';

  static const String _TEMPLATE_TEST_RULE = '_TEMPLATE_TEST_RULE';

  static const String PREFIX_PARSE = 'parse_';

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
  {{#FLAGS}}  
  {{#EXPRESSION}}
  $_ADD_TO_CACHE($_RESULT, pos, {{RULE_ID}});
  {{#LEAVE}}        
  return $_RESULT;
}
''';

  static String _templateWithoutCache = '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}
  {{#FLAGS}}  
  {{#VARIABLES}}  
  {{#EXPRESSION}}
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

    if (parserClassGenerator.parserGenerator.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);
    return block.process();
  }

  List<String> _setFlag() {
    var reset = 0;
    var set = 0;
    var strings = [];
    if (_productionRule.isTerminal) {
      set |= GeneralParserClassGenerator.FLAG_TOKENIZATION;
    }

    if (reset != 0) {
      // strings.add('// $_FLAG &= ${reset};');
    }

    if (set != 0) {
      // strings.add('// $_FLAG |= ${set};');
    }

    return strings;
  }
}
