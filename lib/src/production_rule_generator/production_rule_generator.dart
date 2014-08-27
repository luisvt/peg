part of peg.production_rule_generator;

class ProductionRuleGenerator extends TemplateGenerator {
  static const String VARIABLE_RESULT = "\$\$";

  static const String _ADD_TO_CACHE = MethodAddToCacheGenerator.NAME;

  static const String _CACHE_POS = GrammarGenerator.VARIABLE_CACHE_POS;

  static const String _FLAG = GrammarGenerator.VARIABLE_FLAG;

  static const String _GET_FROM_CACHE = MethodGetFromCacheGenerator.NAME;

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _RESULT = VARIABLE_RESULT;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _TEMPLATE_WITH_CACHE = '_TEMPLATE_WITH_CACHE';

  static const String _TEMPLATE_WITHOUT_CACHE = '_TEMPLATE_WITHOUT_CACHE';

  static const String _TEMPLATE = '_TEMPLATE';

  static const String _TEMPLATE_TEST_RULE = '_TEMPLATE_TEST_RULE';

  static const String PREFIX_PARSE = 'parse_';

  static String _templateWithCache =
      '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}
  {{#VARIABLES}}      
  var pos = $_INPUT_POS;    
  if(pos <= $_CACHE_POS) {
    $_RESULT = $_GET_FROM_CACHE({{RULE_ID}});
  }
  if($_RESULT != null) {
    return $_RESULT[0];       
  }  
  {{#FLAGS}}  
  {{#EXPRESSION}}
  $_ADD_TO_CACHE($_RESULT, pos, {{RULE_ID}});
  {{#LEAVE}}      
  return $_RESULT;
}
''';

  static String _templateWithoutCache =
      '''
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

  GrammarGenerator _grammarGenerator;

  bool _memoize;

  ProductionRule _productionRule;

  Map<String, int> _variables = new Map<String, int>();

  ProductionRuleGenerator(ProductionRule productionRule, GrammarGenerator
      grammarGenerator) {
    if (productionRule == null) {
      throw new ArgumentError('productionRule: $productionRule');
    }

    if (grammarGenerator == null) {
      throw new ArgumentError('grammar: $grammarGenerator');
    }

    _grammarGenerator = grammarGenerator;
    _memoize = grammarGenerator.parserGenerator.memoize;
    _productionRule = productionRule;
    _expressionGenerator = new OrderedChoiceExpressionGenerator(
        productionRule.expression, this);
    _comment = grammarGenerator.parserGenerator.comment;
    addTemplate(_TEMPLATE_WITH_CACHE, _templateWithCache);
    addTemplate(_TEMPLATE_WITHOUT_CACHE, _templateWithoutCache);
  }

  bool get comment {
    return _comment;
  }

  GrammarGenerator get grammarGenerator {
    return _grammarGenerator;
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

  String getMethodName() {
    return '${PREFIX_PARSE}${_productionRule.name}';
  }

  void _assignTraceVariables(TemplateBlock block) {
    var name = _productionRule.name;
    block.assign('#ENTER', "$_TRACE('$name', '>  ');");
    block.assign('#LEAVE', "$_TRACE('$name', ' <' + ($_SUCCESS ? ' ' : '*'));");
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
    var methodName = getMethodName();
    if (comment) {
      var lexical = _productionRule.isTerminal ? 'TERMINAL' : 'NONTERMINAL';
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $_productionRule');
    }

    if(grammarGenerator.parserGenerator.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);
    block.assign('RULE_ID', _productionRule.id);
    return block.process();
  }

  List<String> _generateWithoutCache() {
    var block = getTemplateBlock(_TEMPLATE_WITHOUT_CACHE);
    var methodName = getMethodName();
    if (comment) {
      var lexical = _productionRule.isTerminal ? 'TERMINAL' : 'NONTERMINAL';
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $_productionRule');
    }

    if(grammarGenerator.parserGenerator.trace) {
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
      set |= GrammarGenerator.FLAG_TOKENIZATION;
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
