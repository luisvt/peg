part of peg.interpreter_parser.visitors;

abstract class InstructionCloner<T extends Instruction> implements InstructionVisitor<T> {
  Map<Instruction, Instruction> _cloneMap;

  Set<Instruction> _cloneSet;

  Set<Instruction> processed;

  InstructionCloner() {
    _cloneMap = <Instruction, Instruction>{};
    _cloneSet = new Set<Instruction>();
    processed = new Set<Instruction>();
  }

  Instruction visitAndPredicate(AndPredicateInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction visitAnyCharacter(AnyCharacterInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new AnyCharacterInstruction.parameterized(action: instruction.action);
    addClone(instruction, clone);
    return clone;
  }

  Instruction visitCharacterClass(CharacterClassInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new CharacterClassInstruction.parameterized(action: instruction.action, ranges: instruction.ranges);
    addClone(instruction, clone);
    return clone;
  }

  Instruction visitCharacter(CharacterInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new CharacterInstruction.parameterized(action: instruction.action, character: instruction.character);
    addClone(instruction, clone);
    return clone;
  }

  Instruction visitEmpty(EmptyInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new EmptyInstruction.parameterized(action: instruction.action);
    addClone(instruction, clone);
    return clone;
  }

  Instruction visitLiteral(LiteralInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new LiteralInstruction.parameterized(action: instruction.action, string: instruction.string);
    addClone(instruction, clone);
    return clone;
  }

  Instruction visitNotPredicate(NotPredicateInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction visitOneOrMore(OneOrMoreInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction visitOptional(OptionalInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction visitOrderedChoice(OrderedChoiceInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    var foundInEmpty = new Set<Instruction>();
    var foundInInstructions = new Set<Instruction>();
    var foundInSymbols = new Set<Instruction>();
    foundInInstructions.addAll(instruction.instructions);
    // Check integrity
    for (var group in instruction.symbols.groups) {
      for (var instruction in group.key) {
        foundInSymbols.add(instruction);
        if (!foundInInstructions.contains(instruction)) {
          throw new StateError("Broken ordered choice instruction on '$instruction'.");
        }
      }
    }

    for (var instruction in instruction.empty) {
      foundInEmpty.add(instruction);
      if (!foundInInstructions.contains(instruction)) {
        throw new StateError("Broken ordered choice instruction on '$instruction'.");
      }
    }

    for (var instruction in instruction.instructions) {
      if (!(foundInSymbols.contains(instruction) || foundInEmpty.contains(instruction))) {
        throw new StateError("Broken ordered choice instruction on '$instruction'.");
      }
    }

    clone = new OrderedChoiceInstruction.parameterized(action: instruction.action, flag: instruction.flag);
    addClone(instruction, clone);
    var empty = <Instruction>[];
    var instructions = <Instruction>[];
    var map = <Instruction, Instruction>{};
    var symbols = new SparseList<List<Instruction>>();
    for (var before in instruction.instructions) {
      var after = _accept(before, clone);
      instructions.add(after);
      map[before] = after;
    }

    for (var group in instruction.symbols.groups) {
      var instructions = <Instruction>[];
      for (var instruction in group.key) {
        instructions.add(map[instruction]);
      }

      symbols.addGroup(new GroupedRangeList<List<Instruction>>(group.start, group.end, instructions));
    }

    for (var instruction in empty) {
      empty.add(map[instruction]);
    }

    clone.empty = empty;
    clone.instructions = instructions;
    clone.symbols = symbols;
    return clone;
  }

  Instruction visitProductionRule(ProductionRuleInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new ProductionRuleInstruction.parameterized(action: instruction.action, id: instruction.id, memoize: instruction.memoize, name: instruction.name);
    addClone(instruction, clone);
    clone.instruction = _accept(instruction.instruction, clone);
    return clone;
  }

  Instruction visitRule(RuleInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new RuleInstruction.parameterized(action: instruction.action, name: instruction.name);
    addClone(instruction, clone);
    clone.instruction = _accept(instruction.instruction, clone);
    return clone;
  }

  Instruction visitSequence(SequenceInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    clone = new SequenceInstruction.parameterized(action: instruction.action);
    addClone(instruction, clone);
    var instructions = <Instruction>[];
    for (var child in instruction.instructions) {
      instructions.add(_accept(child, clone));
    }

    clone.instructions = instructions;
    return clone;
  }

  Instruction visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction visitZeroOrMore(ZeroOrMoreInstruction instruction) {
    return _cloneUnary(instruction);
  }

  Instruction _cloneUnary(UnaryInstruction instruction) {
    var clone = getClone(instruction);
    if (clone != null) {
      return clone;
    }

    switch (instruction.type) {
      case InstructionTypes.AND_PREDICATE:
        clone = new AndPredicateInstruction.parameterized(action: instruction.action);
        break;
      case InstructionTypes.NOT_PREDICATE:
        clone = new NotPredicateInstruction.parameterized(action: instruction.action);
        break;
      case InstructionTypes.ONE_OR_MORE:
        clone = new OneOrMoreInstruction.parameterized(action: instruction.action);
        break;
      case InstructionTypes.OPTIONAL:
        clone = new OptionalInstruction.parameterized(action: instruction.action);
        break;
      case InstructionTypes.SEQUENCE_WITH_ONE_ELEMENT:
        clone = new SequenceWithOneElementInstruction.parameterized(action: instruction.action);
        break;
      case InstructionTypes.ZERO_OR_MORE:
        clone = new ZeroOrMoreInstruction.parameterized(action: instruction.action);
        break;
      default:
        throw new StateError("Unknown instruction type: '${instruction.type}'");
    }

    clone = clone as UnaryInstruction;
    addClone(instruction, clone);
    clone.instruction = _accept(instruction.instruction, clone);
    return clone;
  }

  Instruction _accept(Instruction instruction, Instruction dependent) {
    processed.add(dependent);
    instruction = instruction.accept(this);
    processed.remove(dependent);
    return instruction;
  }

  Instruction addClone(Instruction instruction, Instruction clone) {
    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }

    if (clone == null) {
      throw new ArgumentError("clone: $clone");
    }

    if (_cloneSet.contains(clone)) {
      throw new StateError("Clone '${clone.type}' already exists.");
    }

    if (_cloneMap[instruction] != null) {
      throw new StateError("Clone '${clone.type}' already exists.");
    }

    _cloneMap[instruction] = clone;
    _cloneSet.add(clone);
    return clone;
  }

  Instruction getClone(Instruction instruction) {
    var clone = _cloneMap[instruction];
    if (clone != null) {
      return clone;
    }

    if (_cloneSet.contains(instruction)) {
      return instruction;
    }

    return null;
  }
}
