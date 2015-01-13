part of peg.interpreter_parser.optimizer;

class RedundantInstructionRemover extends InstructionCloner {
  int numberOfOptimizations = 0;

  Instruction optimize(Instruction instruction) {
    numberOfOptimizations = 0;
    return instruction.accept(this);
  }

  Instruction visitOrderedChoice(OrderedChoiceInstruction instruction) {
    instruction = super.visitOrderedChoice(instruction);
    if (instruction is! OrderedChoiceInstruction) {
      return instruction;
    }

    var optimizable = false;
    Instruction child;
    if (!processed.contains(instruction)) {
      if (instruction.action == null) {
        var instructions = instruction.instructions;
        if (instructions.length == 1) {
          child = instructions.first;
          if (child.action == null) {
            if (_isPrimitiveInstruction(child)) {
              optimizable = true;
            } else if (child is OrderedChoiceInstruction) {
              // TODO: Transfer error messages
              optimizable = true;
            }
          }
        }
      }
    }

    if (optimizable) {
      numberOfOptimizations++;
      return child;
    } else {
      return instruction;
    }
  }

  Instruction visitProductionRule(ProductionRuleInstruction instruction) {
    instruction = super.visitProductionRule(instruction);
    if (instruction is! ProductionRuleInstruction) {
      return instruction;
    }

    var child = instruction.instruction;
    var optimizable = false;
    if (!processed.contains(instruction)) {
      if (instruction.action == null) {
        if (child.action == null) {
          if (!instruction.memoize) {
            optimizable = true;
          }
        }
      }
    }

    if (optimizable) {
      numberOfOptimizations++;
      return child;
    } else {
      return instruction;
    }
  }

  Instruction visitRule(RuleInstruction instruction) {
    instruction = super.visitRule(instruction);
    if (instruction is! RuleInstruction) {
      return instruction;
    }

    var child = instruction.instruction;
    var optimizable = false;
    if (!processed.contains(instruction)) {
      if (instruction.action == null) {
        if (child.action == null) {
          optimizable = true;
        }
      }
    }

    if (optimizable) {
      numberOfOptimizations++;
      return child;
    } else {
      return instruction;
    }
  }

  Instruction visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction) {
    instruction = super.visitSequenceWithOneElement(instruction);
    if (instruction is! SequenceWithOneElementInstruction) {
      return instruction;
    }

    var child = instruction.instruction;
    var optimizable = false;
    if (!processed.contains(instruction)) {
      if (instruction.action == null) {
        if (child.action == null) {
          optimizable = true;
        }
      }
    }

    if (optimizable) {
      numberOfOptimizations++;
      return child;
    } else {
      return instruction;
    }
  }

  bool _isPrimitiveInstruction(Instruction instruction) {
    switch (instruction.type) {
      case InstructionTypes.ANY_CHARACTER:
      case InstructionTypes.CHARACTER:
      case InstructionTypes.CHARACTER_CLASS:
      case InstructionTypes.LITERAL:
      case InstructionTypes.EMPTY:
        return true;
    }

    return false;
  }
}
