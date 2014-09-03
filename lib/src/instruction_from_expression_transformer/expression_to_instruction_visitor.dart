part of peg.instruction_from_expression_transformer;

class ExpressionToInstructionVisitor extends UnifyingExpressionVisitor<Instruction> {
  List<Instruction> instructions;

  Map<Expression, Instruction> _orderedChoices;

  ExpressionToInstructionVisitor() {
    instructions = <Instruction>[];
    _orderedChoices = <Expression, Instruction>{};
  }

  Instruction visitAndPredicate(AndPredicateExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new AndPredicateInstruction(instruction);
    instructions.add(instruction);
    return instruction;
  }

  Instruction visitAnyCharacter(AnyCharacterExpression expression) {
    var instruction = new AnyCharacterInstruction();
    instructions.add(instruction);
    return instruction;
  }

  Instruction visitCharacterClass(CharacterClassExpression expression) {
    var ranges = expression.ranges;
    var instruction = new CharacterClassInstruction(ranges);
    instructions.add(instruction);
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

    instructions.add(instruction);
    return instruction;
  }

  Instruction visitNotPredicate(NotPredicateExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new NotPredicateInstruction(instruction);
    instructions.add(instruction);
    return instruction;
  }

  Instruction visitOneOrMore(OneOrMoreExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new OneOrMoreInstruction(instruction);
    instructions.add(instruction);
    return instruction;
  }

  Instruction visitOptional(OptionalExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new OptionalInstruction(instruction);
    instructions.add(instruction);
    return instruction;
  }

  Instruction visitOrderedChoice(OrderedChoiceExpression expression) {
    var instruction = _orderedChoices[expression];
    if (instruction != null) {
      return instruction;
    }

    // TODO: !!!Temporarily: Optimize transitions
    var transitions = new SparseList<List<Instruction>>();
    instruction = new OrderedChoiceInstruction(transitions);
    instructions.add(instruction);
    _orderedChoices[expression] = instruction;
    var children = <Instruction>[];
    for (var child in expression.expressions) {
      var instruction = child.accept(this);
      children.add(instruction);
    }

    // TODO: !!!Temporarily to mix them all together into single group
    var unicode = Expression.unicodeGroup;
    var group = new GroupedRangeList<List<Instruction>>(unicode.start, unicode.end, children);
    transitions.addGroup(group);
    return instruction;
  }

  Instruction visitRule(RuleExpression expression) {
    Instruction instruction;
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      instruction = ruleExpression.accept(this);
      instruction = new RuleInstruction(rule.name, instruction);
      instructions.add(instruction);
    }

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
      instruction = new SequenceSingleInstruction(children.first);
    } else {
      instruction = new SequenceInstruction(children);
    }

    instructions.add(instruction);
    return instruction;
  }

  Instruction visitZeroOrMore(ZeroOrMoreExpression expression) {
    var instruction = expression.expression.accept(this);
    instruction = new ZeroOrMoreInstruction(instruction);
    instructions.add(instruction);
    return instruction;
  }
}
