part of peg.instruction_compiler;

class InstructionCompiler {
  List<int> _code;

  List _data;

  void compile(List<Instruction> instructions, List<int> code, List data) {
    _code = code;
    _data = data;
    for (var instruction in instructions) {
      _compile(instruction);
    }
  }

  int _compile(Instruction instruction) {
    switch (instruction.type) {
      case InstructionTypes.AND_PREDICATE:
      case InstructionTypes.NOT_PREDICATE:
      case InstructionTypes.ONE_OR_MORE:
      case InstructionTypes.OPTIONAL:
      case InstructionTypes.SEQUENCE_SINGLE:
      case InstructionTypes.ZERO_OR_MORE:
        return _compileUnary(instruction);
      case InstructionTypes.ANY_CHARACTER:
        return _compileAnyCharacter(instruction);
      case InstructionTypes.CHARACTER:
        return _compileCharacter(instruction);
      case InstructionTypes.CHARACTER_CLASS:
        return _compileCharacterClass(instruction);
      case InstructionTypes.EMPTY:
        return _compileEmpty(instruction);
      case InstructionTypes.LITERAL:
        return _compileLiteral(instruction);
      case InstructionTypes.ORDERED_CHOICE:
        return _compileOrderedChoice(instruction);
      case InstructionTypes.RULE:
        return _compileRule(instruction);
      case InstructionTypes.SEQUENCE:
        return _compileSequence(instruction);
      default:
        throw new StateError("Unknown instruction: $instruction");
    }
  }

  // TODO: Optimize finding and removing data duplication
  int _allocate(List data) {
    var address = _data.length;
    _data.addAll(data);
    return address;
  }

  int _compileAnyCharacter(AnyCharacterInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    return address;
  }

  int _compileCharacter(CharacterInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    _code[address + Instruction.OFFSET_DATA] = _allocate([instruction.character]);
    return address;
  }

  int _compileCharacterClass(CharacterClassInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    var groups = instruction.ranges.groups;
    var length = groups.length;
    var data = new List(1 + length * 2);
    data[CharacterClassInstruction.OFFSET_RANGE_COUNT] = length;
    var i = 0;
    for (var group in groups) {
      data[CharacterClassInstruction.OFFSET_RANGES + i + 0] = group.start;
      data[CharacterClassInstruction.OFFSET_RANGES + i + 1] = group.end;
      i += 2;
    }

    _code[address + Instruction.OFFSET_DATA] = _allocate(data);
    return address;
  }

  int _compileEmpty(EmptyInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    return address;
  }

  int _compileLiteral(LiteralInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    _code[address + Instruction.OFFSET_DATA] = _allocate([instruction.string]);
    return address;
  }

  int _compileOrderedChoice(OrderedChoiceInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    var transitions = instruction.transitions.groups;
    var length = transitions.length;
    var data = new List(1 + length * OrderedChoiceInstruction.SIZE_OF_STRUCT_TRANSITION);
    data[OrderedChoiceInstruction.OFFSET_TRANSITION_COUNT] = transitions.length;
    var i = OrderedChoiceInstruction.OFFSET_TRANSITIONS;
    for (var transition in transitions) {
      var instructions = transition.key;
      var length = instructions.length;
      var addresses = new List<int>(1 + length);
      addresses[OrderedChoiceInstruction.STRUCT_INTRUCTION_COUNT] = length;
      for (var i = 0; i < length; i++) {
        addresses[OrderedChoiceInstruction.STRUCT_INTRUCTION_ELEMENTS + i] = _compile(instructions[i]);
      }

      data[i + OrderedChoiceInstruction.STRUCT_TRANSITION_START] = transition.start;
      data[i + OrderedChoiceInstruction.STRUCT_TRANSITION_END] = transition.end;
      data[i + OrderedChoiceInstruction.STRUCT_TRANSITION_INTSRUCTIONS] = _allocate(addresses);
      i += OrderedChoiceInstruction.SIZE_OF_STRUCT_TRANSITION;
    }

    // start
    // end
    // addresses

    _code[address + Instruction.OFFSET_DATA] = _allocate(data);
    return address;
  }

  int _compileRule(RuleInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    _code[address + Instruction.OFFSET_DATA] = _compile(instruction.instruction);
    return address;
  }

  int _compileSequence(SequenceInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    var instructions = instruction.instructions;
    var length = instructions.length;
    var data = new List(1 + length);
    data[SequenceInstruction.OFFSET_INSTRUCTION_COUNT] = length;
    var i = 0;
    for (var instruction in instructions) {
      data[SequenceInstruction.OFFSET_INSTRUCTIONS + i++] = _compile(instruction);
    }

    _code[address + Instruction.OFFSET_DATA] = _allocate(data);
    return address;
  }

  int _compileUnary(UnaryInstruction instruction) {
    if (instruction.address != null) {
      return instruction.address;
    }

    var address = _writeInstruction(instruction);
    // Data
    _code[address + Instruction.OFFSET_DATA] = _compile(instruction.instruction);
    return address;
  }

  int _writeInstruction(Instruction instruction) {
    if (instruction.address != null) {
      throw new StateError("Instruction '$instruction' already compiled.");
    }

    var address = _code.length;
    instruction.address = address;
    _code.length += Instruction.SIZE;
    _code[address + Instruction.OFFSET_ID] = instruction.type.id;
    _code[address + Instruction.OFFSET_FLAG] = 0;
    _code[address + Instruction.OFFSET_DATA] = 0;
    return address;
  }
}
