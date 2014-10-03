part of peg.interpreter_parser.optimizer;

abstract class InstructionOptimizer extends UnifyingInstructionVisitor {
  Set<Instruction> visited = new Set<Instruction>();

  Instruction visitInstruction(Instruction instruction) {
    if (visited.contains(instruction)) {
      return instruction;
    }

    Instruction optimized = super.visitInstruction(instruction);
    if (optimized != null) {
      instruction = optimized;
    }

    visited.add(instruction);
    return instruction;
  }
}
