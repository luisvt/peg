part of peg.interpreter_parser_generator;

class ExpressionConverter extends UnifyingExpressionVisitor<Instruction> {
  Map<Expression, ProductionRuleInstruction> _productionRules;

  Map<Expression, Instruction> _visited;

  ExpressionConverter() {
    _productionRules = <Expression, ProductionRuleInstruction>{};
    _visited = <Expression, Instruction>{};
  }

  Instruction visitAndPredicate(AndPredicateExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new AndPredicateInstruction(instruction);
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitAnyCharacter(AnyCharacterExpression expression) {
    var instruction = new AnyCharacterInstruction();
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitCharacterClass(CharacterClassExpression expression) {
    var ranges = expression.ranges;
    var instruction = new CharacterClassInstruction(ranges);
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitLiteral(LiteralExpression expression) {
    Instruction instruction;
    var text = expression.text;
    if (text.isEmpty) {
      instruction = new EmptyInstruction();
    } else if (text.length == 1) {
      instruction = new CharacterInstruction(text[0]);
    } else {
      instruction = new LiteralInstruction(text);
    }

    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitNotPredicate(NotPredicateExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new NotPredicateInstruction(instruction);
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitOneOrMore(OneOrMoreExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new OneOrMoreInstruction(instruction);
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitOptional(OptionalExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new OptionalInstruction(instruction);
    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitOrderedChoice(OrderedChoiceExpression expression) {
    var instruction = _visited[expression];
    if (instruction != null) {
      var productionRule = _productionRules[expression];
      if (productionRule != null) {
        return productionRule;
      }

      return instruction;
    }

    var flag = 0;
    if (expression.isOptional) {
      flag |= OrderedChoiceInstruction.FLAG_IS_OPTIONAL;
    }

    var instructions = <Instruction>[];
    // TODO: !!!Temporarily: Optimize transitions
    var empty  = <Instruction>[];
    var symbols = new SparseList<List<Instruction>>();
    instruction = new OrderedChoiceInstruction(instructions, symbols, empty, flag);
    ProductionRuleInstruction parentInstruction;
    // Syntatic ProductionRuleInstruction
    if (expression.parent == null) {
      var owner = expression.owner;
      parentInstruction = new ProductionRuleInstruction(owner.id, owner.name, instruction, false);
      _productionRules[expression] = parentInstruction;
    }


    // TODO: implement
    var transitions2 = new SparseList<List<Instruction>>();

    _visited[expression] = instruction;
    for (var child in expression.expressions) {
      var instruction = child.accept(this);
      instructions.add(instruction);

      for (var group in child.startCharacters.groups) {
        //
        // transitions2.addGroup(new GroupedRangeList<Instruction>(group.start, group.end, instruction));
      }
    }

    // TODO: !!!Temporarily to mix them all together into single group
    var unicode = Expression.unicodeGroup;
    var group = new GroupedRangeList<List<Instruction>>(unicode.start, unicode.end, instructions);
    symbols.addGroup(group);
    // Syntatic ProductionRuleInstruction
    if (parentInstruction != null) {
      return parentInstruction;
    }

    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitRule(RuleExpression expression) {
    Instruction instruction;
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      instruction = ruleExpression.accept(this);
      instruction = new RuleInstruction(rule.name, instruction);
    }

    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var children = <Instruction>[];
    for (var child in expressions) {
      var instruction = child.accept(this);
      children.add(instruction);
    }

    Instruction instruction;
    if (expressions.length == 1) {
      instruction = new SequenceWithOneElementInstruction(children.first);
    } else {
      instruction = new SequenceInstruction(children);
    }

    _setAction(expression, instruction);
    return instruction;
  }

  Instruction visitZeroOrMore(ZeroOrMoreExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new ZeroOrMoreInstruction(instruction);
    _setAction(expression, instruction);
    return instruction;
  }

  void _setAction(Expression expression, Instruction instruction) {
    var action = expression.action;
    if (action  != null) {
      instruction.action = Utils.codeToStrings(action);
    }
  }
}
