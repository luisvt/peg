part of peg.grammar.production_rule;

class ProductionRule {
  int id;

  Set<ProductionRule> allCallees = new Set<ProductionRule>();

  Set<ProductionRule> allCallers = new Set<ProductionRule>();

  Set<ProductionRule> circle = new Set<ProductionRule>();

  Set<ProductionRule> directCallees = new Set<ProductionRule>();

  Set<ProductionRule> directCallers = new Set<ProductionRule>();

  Set<String> expectedLexemes = new Set<String>();

  Set<String> expectedStrings = new Set<String>();

  OrderedChoiceExpression expression;

  bool isStartingRule;

  ProductionRuleKinds kind;

  int numberOfOwnCalls = 0;

  int numberOfCalls = 0;

  final String name;

  ProductionRule parent;

  int tokenId;

  ProductionRule(this.name, this.expression) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (expression == null) {
      throw new ArgumentError('expression: $expression');
    }

    expression.owner = this;
  }

  bool get isLexeme => kind == ProductionRuleKinds.LEXEME;

  bool get isMorpheme => kind == ProductionRuleKinds.MORHEME;

  bool get isRecursive {
    return allCallers.contains(this);
  }

  bool get isSentence => kind == ProductionRuleKinds.SENTENCE;

  bool get isUsed {
    return allCallers.length > 0;
  }

  String getTokenName() {
    if (!isLexeme) {
      return null;
    }

    if (expectedLexemes.length == 1) {
      var first = expectedLexemes.first;
      if (first != null) {
        return first;
      }
    }

    return name;
  }

  String toString() {
    return '$name <- $expression';
  }

  static void addCalls(ProductionRule caller, ProductionRule callee, bool direct) {
    if (caller == null) {
      throw new ArgumentError('caller: $caller');
    }

    if (callee == null) {
      throw new ArgumentError('callee: $callee');
    }

    var foundInAllCallees = caller.allCallees.contains(callee);
    var foundInAllCallers = callee.allCallers.contains(caller);
    var foundInDirectCallees = caller.directCallees.contains(callee);
    var foundInDirectCallers = callee.directCallers.contains(caller);
    if (direct && !foundInDirectCallees) {
      caller.directCallees.add(callee);
    }

    if (direct && !foundInDirectCallers) {
      callee.directCallers.add(caller);
    }

    if (!foundInAllCallees) {
      caller.allCallees.add(callee);
      caller.allCallees.addAll(callee.allCallees);
      for (var callee in caller.allCallees) {
        addCalls(caller, callee, false);
      }
    }

    if (!foundInAllCallers) {
      callee.allCallers.add(caller);
      callee.allCallers.addAll(caller.allCallers);
      for (var caller in caller.allCallers) {
        addCalls(caller, callee, false);
      }
    }
  }
}

class ProductionRuleKinds {
  static const ProductionRuleKinds LEXEME = const ProductionRuleKinds("LEXEME");

  static const ProductionRuleKinds MORHEME = const ProductionRuleKinds("MORHEME");

  static const ProductionRuleKinds SENTENCE = const ProductionRuleKinds("SENTENCE");

  final String _name;

  const ProductionRuleKinds(this._name);

  String toString() => _name;
}
